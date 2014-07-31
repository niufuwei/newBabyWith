//
//  CameraPlayViewController.m
//  AiJiaJia
//
//  Created by wangminhong on 13-6-17.
//  Copyright (c) 2013年 shancheng.com. All rights reserved.
//

#import "CameraPlayViewController.h"
#import "CameraSettingViewController.h"
#import "WebInfoManager.h"
#import "UIViewController+Alert.h"
#include "Configuration.h"
#import "MainAppDelegate.h"
#import "DeviceConnectManager.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "CameraPhotoRecordViewController.h"
#import "BaseNavigationController.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "SQLiteManager.h"
#import "SharedPersonsViewController.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "mytoast.h"
#define REUSEABLE @"cell"
#define ITEM_WIDTH  (64)
#define ITEM_HEIGTH (36)
#define kArchivingDataKey @"record_image"
AVAudioPlayer *photoSound;           //播放拍照时候的声音


@implementation CameraPlayViewController

@synthesize playView =  _playView;
@synthesize m_PPPPChannelMgtCondition = _m_PPPPChannelMgtCondition;
@synthesize cameraID = _cameraID;
@synthesize imageArray = _imageArray;


-(double)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    
    return  [[fattributes objectForKey:NSFileSystemFreeSize] doubleValue];
}
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    }
    return self;
}


-(void)loadView
{
    UIView *view = [[ UIView alloc] initWithFrame:CGRectMake(0, 0, 320, [[UIScreen mainScreen] applicationFrame].size.height)];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];

    _isFirst=TRUE;
    
    NSLog(@"camera play view did load!");
    [self titleSet:[[appDelegate.appDefault objectForKey:@"Device_selected"] objectForKey:@"name"]];

    //默认是非截屏状态
    screenshots = 0;
    
    
    
    
    for (id obj in [appDelegate.deviceConnectManager getDeviceInfoList])
    {
        NSLog(@"本设备信息是%@",obj);
        NSDictionary *dic = (NSDictionary *)obj;
        
        if ([[dic objectForKey:@"name"] isEqualToString:[[appDelegate.appDefault objectForKey:@"Device_selected"] objectForKey:@"name"]])
        {
            
            
            if ([[[dic objectForKey:@"id_member"] stringValue] isEqualToString:@"1"])
            {
                UIButton *navButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
                [navButton setTitle:@"设置" forState:UIControlStateNormal];
                [navButton addTarget:self action:@selector(cameraSettings:) forControlEvents:UIControlEventTouchUpInside];
                UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: navButton];
                self.navigationItem.rightBarButtonItem = rightItem;
            }
            
            
        }
    }
    
    
    
     _switchFlag = 0;  //0是没有连接，1是开始连接
    
    
    //显示视频的画面
    _playView = [[OpenGLView20 alloc] initWithFrame:CGRectMake(0, 0, 320,  180)];
    [_playView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cameraBackView.png"]]];
    [_playView setVideoSize:320 height:180];
    [self.view addSubview:_playView];
    [self imageAddGest:_playView];//增加手势，让摄像头可以左右上下旋转
    
    
    //显示截图的collectionView
    UICollectionViewFlowLayout *cvl = [[UICollectionViewFlowLayout alloc]init];
    cvl.itemSize=CGSizeMake(ITEM_WIDTH, ITEM_HEIGTH);
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 185+44, 320, self.view.frame.size.height - 190 -44 -44 -44) collectionViewLayout:cvl];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_collectionView];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:REUSEABLE];
    
    //横屏工具条，横评的时候才出现
    _lView = [[UIView alloc]init];
    _lView.frame = CGRectMake(0, 0, 320, 60);
    _lView.backgroundColor=[UIColor blackColor];
    _lView.alpha=0.5;
    _lView.hidden = YES;
    
    
    screenshotsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    screenshotsButton.frame = CGRectMake(10, 10, 60, 40);
    screenshotsButton.tag = 1;
    [screenshotsButton setBackgroundImage:[UIImage imageNamed:@"切图_02.png"] forState:UIControlStateNormal];
    [screenshotsButton setBackgroundImage:[UIImage imageNamed:@"切图_20.png"] forState:UIControlStateHighlighted];
    [screenshotsButton addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:screenshotsButton];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.tag = 2;
    button2.frame = CGRectMake(self.view.frame.size.height/6, 10, 60, 40);
    [button2 setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.tag = 3;
    button3.frame = CGRectMake( self.view.frame.size.height*2/6,10, 60, 40);
    [button3 setBackgroundImage:[UIImage imageNamed:@"切图_06.png"] forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:button3];

    

    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.tag = 13;
    button4.frame = CGRectMake( self.view.frame.size.height*3/6,10, 60, 40);
    [button4 setBackgroundImage:[UIImage imageNamed:@"切图_24.png"] forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:button4];


    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeCustom];
    button5.tag = 14;
    button5.frame = CGRectMake( self.view.frame.size.height*3/6,10, 60, 40);
    [button5 setBackgroundImage:[UIImage imageNamed:@"切图_08.png"] forState:UIControlStateNormal];
    
    [button5 addTarget:self action:@selector(startListen:) forControlEvents:UIControlEventTouchUpInside];
    [button5 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [_lView addSubview:button5];
    button5.hidden = YES;

    
    UIButton *button6 = [UIButton buttonWithType:UIButtonTypeCustom];
    button6.tag = 15;
    button6.frame = CGRectMake( self.view.frame.size.height*4/6,10, 60, 40);
    [button6 setBackgroundImage:[UIImage imageNamed:@"切图_10.png"] forState:UIControlStateNormal];
    [button6 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:button6];
    button6.hidden = YES;


    UIButton *button7 = [UIButton buttonWithType:UIButtonTypeCustom];
    button7.tag = 4;
    button7.frame = CGRectMake(self.view.frame.size.height*5/6,10, 60, 40);
    [button7 setBackgroundImage:[UIImage imageNamed:@"切图_退出全屏.png"] forState:UIControlStateNormal];
    [button7 addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lView addSubview:button7];
    
    [self.view addSubview:_lView];

    
    //竖屏时候的工具条
    _pView = [[UIView alloc]init];
    _pView.frame = CGRectMake(0, 180, 320, 44);
    //_pView.tintColor = babywith_green_color;
    //sc.userInteractionEnabled = NO;
    for (int i = 0; i<4; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i+1;
        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"切图_%d.png",i+54]] forState:UIControlStateNormal];
//        [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"切图_%d.png",i+60]] forState:UIControlStateSelected];
        [button setTitleColor:babywith_green_color forState:UIControlStateNormal];
        button.frame = CGRectMake(320/4*i, 0, 320/4, 44);
        [button addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_pView addSubview:button];
    }
    [self.view addSubview:_pView];
    
    

    //竖屏工对讲条
    _lTalkView = [[UIView alloc]init];
    _lTalkView.frame = CGRectMake(0, self.view.frame.size.height-44-44, 320, 44);
    [self.view addSubview:_lTalkView];
    
    //开启对讲
    UIButton *startTalkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startTalkButton.tag = 13;
    [startTalkButton setBackgroundImage:[UIImage imageNamed:@"切图_71.png"] forState:UIControlStateNormal];
    startTalkButton.frame = CGRectMake(40 ,5 ,240 ,34);
    [startTalkButton addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lTalkView addSubview:startTalkButton];
    //按住说话
    UIButton *pressTalkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pressTalkButton.tag = 14;
    [pressTalkButton setBackgroundImage:[UIImage imageNamed:@"切图_74.png"] forState:UIControlStateNormal];
    pressTalkButton.frame = CGRectMake(0 ,5 ,320/4+20 ,34);
    [pressTalkButton addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [pressTalkButton addTarget:self action:@selector(startListen:) forControlEvents:UIControlEventTouchUpInside];
    [_lTalkView addSubview:pressTalkButton];
    pressTalkButton.hidden = YES;
    
    UIButton *endTalkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    endTalkButton.tag = 15;
    [endTalkButton setBackgroundImage:[UIImage imageNamed:@"切图_76.png"] forState:UIControlStateNormal];
    endTalkButton.frame = CGRectMake(240-20 ,5 ,320/4+20 ,34);
    [endTalkButton addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_lTalkView addSubview:endTalkButton];
    endTalkButton.hidden = YES;

    
    
    
    _rotateEnableFlag = 1;
    _orientationFlag = 0;
    
    _wifiFlag = 0;
    _listenFlag= 0;
    _talkFlag = 0;
    
    _errorMsg = [[NSString alloc] init];
    _currentDeviceDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    _recordData = [[NSMutableData alloc] init];
    _isRecord = 3;
    _recordImage = nil;
    _vedioHasRecord = 0;
    hasSavedVideoImage = TRUE;
    
//    appDelegate.m_PPPPChannelMgt->pCameraViewController = self;
    PPPP_Initialize((char*)"EFGBFFBJKDJBGNJBEBGMFOEIHPNFHGNOGHFBBOCPAJJOLDLNDBAHCOOPGJLMJGLKAOMPLMDIOLMFAFCJJPNEIGAM");
    
    InitAudioSession();
    
    //照相机拍照声音
    NSString *musicFilePath = [[NSBundle mainBundle] pathForResource:@"camera" ofType:@"wav"];
    NSURL *musicURL = [NSURL URLWithString:musicFilePath];
    if (photoSound == nil) {
        photoSound = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    }
    [photoSound prepareToPlay];
    [photoSound setVolume:1];
    photoSound.numberOfLoops = 0;
    
    _imageArray = [[NSMutableArray alloc] initWithCapacity:1];
    _collectionImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GoBackground:) name:@"GoBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becameActive:) name:@"becameActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillResignActive:) name:@"WillResignActive" object:nil];
    
    
    _currentDeviceDic  = [appDelegate.appDefault objectForKey:@"Device_selected"];
    NSLog(@"current dic is %@",_currentDeviceDic);
    
    

    
}

-(void)LockPress:(UIButton *)sender{
    
    if (_lockFlag == 0) {
        [sender setImage:[UIImage imageNamed:@"lock_on.png"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"lock_on_highlighted.png"] forState:UIControlStateHighlighted];
        _lockFlag = 1;
        
        [self hideToolBar];
    }else{
        [sender setImage:[UIImage imageNamed:@"lock_off.png"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"lock_off_highlighted.png"] forState:UIControlStateHighlighted];
        _lockFlag = 0;
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_orientationFlag == 1)
    { //横屏
        if (_toolBarHiddenFlag == 0)
        { //工具栏显示
            UITouch *touch = [touches anyObject];
            CGPoint point = [touch  locationInView:self.view];
            if(point.y < 52 || point.y > 268)
            {
                if (_switchFlag == 0 || _listenFlag == 1)
                {
                    return;
                }
                
                if (_hiddenTimer)
                {
                    [_hiddenTimer invalidate];
                    _hiddenTimer = nil;
                }
                _touchFlag = 1;
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_orientationFlag == 1)
    { //横屏
        if (_toolBarHiddenFlag == 0)
        { //工具栏显示
            UITouch *touch = [touches anyObject];
            CGPoint point = [touch  locationInView:self.view];
            if(point.y < 52 || point.y > 268)
            {
                if (_switchFlag == 0 || _listenFlag == 1)
                {
                    return;
                }
                _touchFlag = 0;
                if (_hiddenTimer)
                {
                    [_hiddenTimer invalidate];
                    _hiddenTimer = nil;
                }
                _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideToolBar) userInfo:nil repeats:YES];
            }
        }
    }
}

-(NSInteger)EnableRotate{
    
    if((_orientationFlag == 0) && (_switchFlag == 0)) {
        return 0;
    }
    
    if (_rotateEnableFlag == 1) {
        return  1-_lockFlag;
    }
    return _rotateEnableFlag;
}

-(void)addTapGest:(UIView *)view{
    
    //单击事件
    UITapGestureRecognizer *taprecognizer;
    taprecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopCameraConnect:)];
    taprecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:taprecognizer];
}

-(void)stopCameraConnect:(UITapGestureRecognizer *)taprecognizer{
    NSLog(@"stop connect flag =======");
    if (_finishFlag != 0) {
        _stopConnectFlag = 1;//没有完成的时候就不停止连接
        NSLog(@"stop connect flag = [%d] [%d]", _finishFlag, _stopConnectFlag);
    }
}

//增加手势
-(void) viewAddGest:(UICollectionViewCell *)view{
    //单击事件
    
    NSLog(@"手势识别");
    UITapGestureRecognizer *taprecognizer;
    taprecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchBlankView:)];
    taprecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:taprecognizer];
    [self touchBlankView];
}

//-(void)touchBlankView:(UITapGestureRecognizer *)taprecognizer{
//    
//    if (taprecognizer.numberOfTapsRequired == 1) {
//        [self touchBlankView];
//    }
//}

-(void)touchBlankView
{
    [self ActionForStopVideo:0 RemindFlag:1];
 
    NSLog(@"currentpage is%d",_currentPage);
    _cameraPhotoRecordViewController = [[CameraPhotoRecordViewController alloc] initWithArray:_imageArray Type:0 CurrentPage:_currentPage Delegate:nil];
    
    //[_snapImageView removeFromSuperview];
    _photoCount = 0;
    [_imageArray removeAllObjects];
    [_collectionImageArray removeAllObjects];
    [self.collectionView reloadData];
    
    [self.navigationController pushViewController: _cameraPhotoRecordViewController animated:YES];
    

}

- (void)startListen:(UIButton *)button
{
    //ULog(@"startListen:");
    //停止对讲
    appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
    
    //启动收听
    appDelegate.m_PPPPChannelMgt->StartPPPPAudio([_cameraID UTF8String]);
}
#pragma mark -点击按钮引发的事件

-(void)timerFired:(UIImage *)screenshotsImage
{
    
    //创建时间
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSData *imageData = UIImageJPEGRepresentation(screenshotsImage ,0.3);
    NSLog(@"data length =[%lu]", (unsigned long)[imageData length]);
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpDir =  NSTemporaryDirectory();
    NSString *filePath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f", time*1000]];
    if (![fileManager createFileAtPath:filePath contents:imageData attributes:nil])
    {
        [self makeAlert:@"保存图片出错"];
    }
    
    //得到年月日
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComp = [myCal components:units fromDate:date];
    //记录ID
    NSString *record_id_save = [NSString stringWithFormat:@"%f_%@",time,[appDelegate.appDefault objectForKey:@"Member_id_self"]];
    //图片相对路径
    NSString *path = [NSString stringWithFormat:@"/image/record/%d/%d/%d/%d/%@.png",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id_save];
    
    
    //保存图片到沙盒目录
    NSString *imagePath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path]];
    NSString *imageDir = [NSString stringWithFormat:@"%@",[imagePath stringByDeletingLastPathComponent]];
    
    NSError *error = nil;
    [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:&error];
    
    //视频流相对路径
    //这里加入了视频流的路径，让所有的图片保存保持一样的参数，但是在这里并没有存入视频，取的时候也不会用到这个视频的路径
    NSString *path1 = [NSString stringWithFormat:@"/vedio/record/%d/%d/%d/%d/%@.pm4",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id_save];
    NSString *vedioPath1 = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path1]];
    NSString *vedioDir = [NSString stringWithFormat:@"%@",[vedioPath1 stringByDeletingLastPathComponent]];
    NSError *vedioError = nil;
    [fileManager createDirectoryAtPath:vedioDir withIntermediateDirectories:YES attributes:nil error:&vedioError];
    
    
    
    //获取快照
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:filePath,@"image",[NSString stringWithFormat:@"%.0f", time*1000], @"time", date, @"date", [NSString stringWithFormat:@"%d", 320], @"width", [NSString stringWithFormat:@"%d", 180], @"height",[NSString stringWithFormat:@"%d",0],@"is_vedio",path1,@"record_data_path",nil];
    
    
    [_collectionImageArray addObject:[UIImage imageWithData:imageData scale:1.0]];
    
    
    
    if (!error)
    {
        if ([fileManager createFileAtPath:imagePath contents:imageData attributes:nil])
        {
            //插入表库
            NSArray *array = [NSArray arrayWithObjects:record_id_save,[appDelegate.appDefault objectForKey:@"Member_id_self"],[dic objectForKey:@"time"],[NSString stringWithFormat:@"%d",[nowComp year]],[NSString stringWithFormat:@"%d",[nowComp month]],[NSString stringWithFormat:@"%d",[nowComp day]],[dic objectForKey:@"width"],[dic objectForKey:@"height"],path,[dic objectForKey:@"is_vedio"],[dic objectForKey:@"record_data_path"],nil];
            
            NSArray *keyArray = [NSArray arrayWithObjects:@"id_record", @"id_member", @"time_record",@"year_record",@"month_record",@"day_record",@"width_image",@"height_image",@"path",@"is_vedio",@"record_data_path", nil];
            NSDictionary *insertDic = [NSDictionary dictionaryWithObjects:array forKeys:keyArray];
            
            
            //插入到数据库
            if([appDelegate.sqliteManager insertRecordInfo:insertDic])
            {
                
                NSLog(@"%@",@"插入到数据库");
                [_imageArray addObject:insertDic];
                
                _photoCount += 1;
                
                ((UIButton *)[_lView viewWithTag:1]).enabled = YES;
                ((UIButton *)[_pView viewWithTag:1]).enabled = YES;
                
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isSaveVideo"];
        }
        
    }
    else
    {
        [self makeAlert:@"保存图片错误!"];
        
        

    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        screenshotsButton.enabled = YES;
        [_collectionView reloadData];
        
    });

}

-(void)ButtonPressed:(UIButton *)button{
  
    //截屏
    if (button.tag == 1)
    {
        screenshots =1;
        
    }
    else if(button.tag == 2)//录制视频
    {
    
        _isStart = !_isStart;
        if (_isStart)
        {
            _isRecord = 1;
            [button setUserInteractionEnabled:NO];
            
            [self performSelector:@selector(findBtn) withObject:self afterDelay:1.0];
            if (_isFullScreen) {
                [button setBackgroundImage:[UIImage imageNamed:@"切图_21.png"] forState:UIControlStateNormal];
            }
            else
            {
                [button setBackgroundImage:[UIImage imageNamed:@"切图_61.png"] forState:UIControlStateNormal];
            }
            
            hasSavedVideoImage = TRUE;
            NSLog(@"开始录制");
        }
        else
        {
            [button setUserInteractionEnabled:NO];
            _isRecord = 2;
            if (_isFullScreen) {
                [button setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
            }
            else
            {
                [button setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
            }
            
            
            
            //否则提示至少选择一台设备
            UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
            indicator.labelText = @"保存视频";
            indicator.mode = MBProgressHUDModeText;
            [window addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                sleep(1);
            } completionBlock:^{
                [indicator removeFromSuperview];
                [self.collectionView reloadData];
                [button setUserInteractionEnabled:YES];

            }];
            
            
        }
      
        
    }
    else if (button.tag == 3)
    {
        
        if(_isRecord==1)
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在录制，是否保存?" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"不保存", nil];
            alert.tag =33333;
            [alert show];
        }
        else
        {
            [self ActionForStopVideo:0 RemindFlag:1];
            appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
            
            appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
            _talkFlag = 0;

            
            
            
            [_lTalkView viewWithTag:13].hidden = NO;
            [_lTalkView viewWithTag:14].hidden = YES;
            [_lTalkView viewWithTag:15].hidden = YES;
            
            [_lView viewWithTag:13].hidden = NO;
            [_lView viewWithTag:14].hidden = YES;
            [_lView viewWithTag:15].hidden = YES;
            
            
            self.navigationController.navigationBarHidden=NO;
            SharedPersonsViewController *sharedPersonVC = [[SharedPersonsViewController alloc] initWithDeviceID:[_currentDeviceDic objectForKey:@"device_id"]];
            
            [self.navigationController pushViewController:sharedPersonVC animated:YES];
        }
        
        
        

    }
    else if(button.tag == 13)
    {//开启对讲
        _isViode=TRUE;
        NSLog(@"start Talk ============");
        button.hidden = YES;
        if (!_isFullScreen)
        {
            [_lTalkView viewWithTag:14].hidden = NO;
            [_lTalkView viewWithTag:15].hidden = NO;
        }
        else
        {
            [_lView viewWithTag:14].hidden = NO;
            [_lView viewWithTag:15].hidden = NO;
        }
        
        //启动收听
        appDelegate.m_PPPPChannelMgt->StartPPPPAudio([_cameraID UTF8String]);
    }
    else if (button.tag == 14)//按住说话
    {
     //停止收听
        if (_isFullScreen)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"切图_23.png"] forState:UIControlEventTouchDown];
        }
        
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        
        //启动对讲
        appDelegate.m_PPPPChannelMgt->StartPPPPTalk([_cameraID UTF8String]);
    
    }
    else if (button.tag == 15)//结束对讲
    {
        _isViode=FALSE;
        button.hidden = YES;
        if (!_isFullScreen) {
            [_lTalkView viewWithTag:13].hidden = NO;
            [_lTalkView viewWithTag:14].hidden = YES;
        }else{
            [_lView viewWithTag:13].hidden = NO;
            [_lView viewWithTag:14].hidden = YES;
        }
        //停止对讲
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        //停止收听
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);

    
    }
    else if (button.tag == 4)
    {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"hasComeBackFromBackground"] == 1)
        {
            [_lView viewWithTag:13].hidden = NO;
            [_lView viewWithTag:14].hidden = YES;
            [_lView viewWithTag:15].hidden = YES;
            
            
            [_lTalkView viewWithTag:13].hidden = NO;
            [_lTalkView viewWithTag:14].hidden = YES;
            [_lTalkView viewWithTag:15].hidden = YES;
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"hasComeBackFromBackground"];
        }
        
        
        
        
        
        if (_isRecord==1) {
            UIButton *btn = (UIButton *)[_lView viewWithTag:2];
            [btn setBackgroundImage:[UIImage imageNamed:@"切图_21.png"] forState:UIControlStateNormal];
            
            UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"切图_61.png"] forState:UIControlStateNormal];
            
        }
        else
        {
            UIButton *btn = (UIButton *)[_lView viewWithTag:2];
            [btn setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
            
            UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
        }
        
        
        if (_isViode) {
            [_lView viewWithTag:13].hidden = YES;
            [_lView viewWithTag:14].hidden = NO;
            [_lView viewWithTag:15].hidden = NO;
            
            [_lTalkView viewWithTag:13].hidden = YES;
            [_lTalkView viewWithTag:14].hidden = NO;
            [_lTalkView viewWithTag:15].hidden = NO;


        }
        else
        {
            [_lView viewWithTag:13].hidden = NO;
            [_lView viewWithTag:14].hidden = YES;
            [_lView viewWithTag:15].hidden = YES;
            
            [_lTalkView viewWithTag:13].hidden = NO;
            [_lTalkView viewWithTag:14].hidden = YES;
            [_lTalkView viewWithTag:15].hidden = YES;

            
        }
        
        
        //进入全屏或者退出全屏
        if (!_isFullScreen)
        {
            _isScreen=TRUE;
            [[NSUserDefaults standardUserDefaults]setObject:@"yes" forKey:@"isScreen"];
            [UIApplication sharedApplication].statusBarHidden = YES;
            self.navigationController.navigationBarHidden = YES;
            self.collectionView.hidden = YES;
            [UIView animateWithDuration:0.0f animations:^{
                _pView.hidden = YES;
                _lView.hidden = NO;
                _lView.frame = CGRectMake(0, 320-60, self.view.frame.size.height, 60);
                [self.view setTransform: CGAffineTransformMakeRotation(M_PI / 2)];
                
                if(kIsIphone5)
                {
                    
                    _playView.frame = CGRectMake(0, 0, 568, 320);
                    
                }
                
                else
                {
                    
                    _playView.frame = CGRectMake(0, 0, 480, 320);
                    
                }
              
            }];
            

        }
        else
        {
            
            
            
            _isScreen=FALSE;
            [[NSUserDefaults standardUserDefaults]setObject:@"no" forKey:@"isScreen"];
            [UIApplication sharedApplication].statusBarHidden = NO;
            self.navigationController.navigationBarHidden = NO;
            self.collectionView.hidden = NO;
            [UIView animateWithDuration:0.0f animations:^{
                _lView.hidden = YES;
                _pView.hidden = NO;
                [self.view setTransform: CGAffineTransformRotate(self.view.transform,(-M_PI/2))];
                
                if(kIsIphone5)
                {
                    
                    _playView.frame = CGRectMake(0, 0, 320, 180);
                    
                }
                
                else
                {
                    
                    _playView.frame = CGRectMake(0, 0, 320, 180);
                    
                }
            }];
            

        }
        _isFullScreen = !_isFullScreen;
    
    }
}

-(IBAction)findBtn
{
    UIButton *btn = (UIButton *)[_lView viewWithTag:2];
    [btn setUserInteractionEnabled:YES];
    
    UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
   
    [btn1 setUserInteractionEnabled:YES];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    
    if ([appDelegate.appDefault integerForKey:@"Relative_login_flag"] == 1)
    {
        if (error == nil)
        {
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
            indicator.labelText = @"照片已经保存至相册中。";
            indicator.mode = MBProgressHUDModeText;
            [self.view addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                sleep(1.2);
            } completionBlock:^{
                [indicator removeFromSuperview];
            }];
        }
        else
        {
            if (error.code == ALAssetsLibraryAccessUserDeniedError || error.code == ALAssetsLibraryDataUnavailableError)
            {
                NSLog(@"error code == ALAssetsLibraryAccessUserDeniedError");
                [self makeAlert:@"您已关闭相册权限，如需开启，请在iPhone的“设置”-“隐私”-“照片”功能中，找到应用程序“BabyWith”进行更改"];
            }
            else
            {
                NSLog(@"SAVE IMAGE ERROR=[%@][%d]", [error localizedDescription],error.code);
                [self makeAlert:@"保存照片出错"];
            }
        }
    }
}



#pragma mark -ImageNotifyProtocol
- (void) ImageNotify: (UIImage *)image timestamp: (NSInteger)timestamp DID:(NSString *)did
{
    //[self performSelector:@selector(refreshImage:) withObject:image];
    
    
    NSLog(@"图片切换");
}
- (void) YUVNotify: (Byte*) yuv length:(int)length width: (int) width height:(int)height timestamp:(unsigned int)timestamp DID:(NSString *)did
{
    
    
    [_playView displayYUV420pData:yuv width:width height:height];
    
//
//    NSLog(@"lenght is %d,width is %d,height is %d",length,width,height);
//    
        _isFirst = !_isFirst;

    //screenshots ==0 非截屏，   ＝＝1 截屏
    if(screenshots==1)
    {
        //得到开始录制的时候的第一张图片
        [self timerFired: [APICommon YUV420ToImage:yuv width:width height:height]];
        screenshots = 0;
    }

    if (_isRecord ==1 )//开始录制
    {
        NSLog(@"0000000000000%f",[self freeDiskSpace]/1024.0/1024.0/1024.0);
        
    
        if ([self freeDiskSpace]/1024.0/1024.0 < 300.00)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [mytoast showWithText:@"内存不足，自动保存视频"];
                
                UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
                [btn1 setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
                
                
                UIButton *btn2 = (UIButton *)[_lView viewWithTag:2];
                [btn2 setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
            });

           
            [appDelegate.appDefault setObject:@"1" forKey:@"diskSpaceIsFull"];
            
            _isRecord = 2;
            _isStart = false;
            
           
        }
        else
        {
        
            [appDelegate.appDefault setObject:@"0" forKey:@"diskSpaceIsFull"];
        
        //第一次进来开始录制的时候取得第一张图片，录制过程中不需要图片，只需要数据
        if (!_recordImage)
        {
            //得到开始录制的时候的第一张图片
            UIImage* image = [APICommon YUV420ToImage:yuv width:width height:height];
            _recordImage = image;
            NSLog(@"record image is %@",_recordImage);
            NSDate *date = [NSDate date];
            NSTimeInterval time = [date timeIntervalSince1970];

            //得到年月日
            unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
            NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *nowComp = [myCal components:units fromDate:date];
            //记录ID
           record_id = [NSString stringWithFormat:@"%f_%@",time,[appDelegate.appDefault objectForKey:@"Member_id_self"]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];

            //视频流相对路径
            NSString *path1 = [NSString stringWithFormat:@"/vedio/record/%d/%d/%d/%d/%@320x240.264",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id];
            vedioPath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path1]];
            NSString *vedioDir = [NSString stringWithFormat:@"%@",[vedioPath stringByDeletingLastPathComponent]];
            NSError *vedioError = nil;
            [fileManager createDirectoryAtPath:vedioDir withIntermediateDirectories:YES attributes:nil error:&vedioError];

            [_recordData appendBytes:yuv length:length];
            _vedioHasRecord = 0;
            if ([fileManager createFileAtPath:vedioPath contents:_recordData attributes:nil])
            {
                _recordData = nil;
                _vedioHasRecord = 1;//视频保存成功
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isSaveVideo"];
            }
            else
            {
                
                
                [self makeAlert:@"保存视频出错"];
            }

        }
        else
        {
            
            
            if (_recordImage)
            {
                NSLog(@"有图片");
            }
            else
            {
            
            
                NSLog(@"没有图片");
            
            }
                
                if (hasSavedVideoImage)
                {
                    
                    NSLog(@"record image %@",_recordImage);
                    [self savePicAndVideo];
                }
            
                
                
                
            //得到视频数据
                _recordData =nil;
                _recordData = [[NSMutableData alloc] init];

                [_recordData appendBytes:yuv length:length];
                
                NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:vedioPath];
                
                if(fileHandle == nil)
                    
                {
                    
                    return;
                    
                }
                
                [fileHandle seekToEndOfFile];
                
                [fileHandle writeData:_recordData];
                
                [fileHandle closeFile];
        
                NSLog(@"我在保存数据");
                
               
            }
        }
    }
    if(_isRecord ==2)
        //停止录制
    {
        //[self savePicAndVideo];
        //这里对照片直接进行保存
        if ([[appDelegate.appDefault objectForKey:@"diskSpaceIsFull"] isEqualToString:@"0"])
        {
            [_imageArray addObject:insertDict1];
            [self.collectionImageArray addObject:_recordImage];
            [self.collectionView reloadData];

        }
        
        
        _isRecord = 3;//回到normal状态下的值，开始录制是1，完成了录制是2
        _recordImage = nil;//保证下次再录制的时候得到下一次的第一张图片

    }
}

-(void)savePicAndVideo
{
    //照片和视频都在这里保存
    //创建时间
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    //图片转换成数据
    NSLog(@"image data is %@",_recordImage);
    
    
    
    
    
    NSData *imageData = UIImageJPEGRepresentation(_recordImage ,0.3);
    NSLog(@"data length =[%lu]", (unsigned long)[imageData length]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tmpDir =  NSTemporaryDirectory();
    NSString *filePath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f", time*1000]];
    if (![fileManager createFileAtPath:filePath contents:imageData attributes:nil])
    {
        [self makeAlert:@"保存图片出错"];
    }
    
    //得到年月日
    unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *nowComp = [myCal components:units fromDate:date];
    
    //视频流相对路径
    NSString *path1 = [NSString stringWithFormat:@"/vedio/record/%d/%d/%d/%d/%@320x240.264",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id];
    //获取快照,这里加入了图片对应视频的路径，方便以后找到对应的视频
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:filePath,@"image",[NSString stringWithFormat:@"%.0f", time*1000], @"time", date, @"date", [NSString stringWithFormat:@"%d", 320], @"width", [NSString stringWithFormat:@"%d", 180], @"height",[NSString stringWithFormat:@"%d",1],@"is_vedio",path1,@"record_data_path",nil];
    
    //图片相对路径
    NSString *path = [NSString stringWithFormat:@"/image/record/%d/%d/%d/%d/%@.png", [nowComp year],[nowComp month], [nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id];
    
    //保存图片至沙盒目录
    NSString *imagePath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path]];
    imagePath1 = [NSString stringWithFormat:@"%@",imagePath];
    NSString *imageDir = [NSString stringWithFormat:@"%@", [imagePath stringByDeletingLastPathComponent]];
    NSError *error = nil;
    [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:&error];
    //如果视频保存成功了才去保存图片
    if (!error && _vedioHasRecord ==1)
    {
        
        if ([fileManager createFileAtPath:imagePath contents:imageData attributes:nil])
        {
            //插入库表
            NSArray *array = [NSArray arrayWithObjects:record_id,[appDelegate.appDefault objectForKey:@"Member_id_self"],[dic objectForKey:@"time"],[NSString stringWithFormat:@"%d",[nowComp year]],[NSString stringWithFormat:@"%d",[nowComp month]], [NSString stringWithFormat:@"%d",[nowComp day]],[dic objectForKey:@"width"],[dic objectForKey:@"height"], path,[NSString stringWithFormat:@"%d",1],path1, nil];
            
            
            NSArray *keyArray = [NSArray arrayWithObjects:@"id_record", @"id_member", @"time_record",@"year_record",@"month_record",@"day_record", @"width_image",@"height_image",@"path",@"is_vedio",@"record_data_path",nil];
            NSDictionary *insertDic = [NSDictionary dictionaryWithObjects:array forKeys:keyArray];
            
            if ([appDelegate.sqliteManager insertRecordInfo:insertDic])
            {
                insertDict1 = [ NSDictionary dictionaryWithDictionary:insertDic];
                
                
                _vedioHasRecord = 0;
                
                
                _photoCount += 1;
                NSLog(@"这里走了没有呢");
                hasSavedVideoImage = FALSE;
                
                
            }
            else
            {
                //删除图片
                
                [self makeAlert:@"保存视频错误！"];
            }
        }
        else
        {
            [self makeAlert:@"保存视频错误！"];
        }
    }
    
//    _isRecord = 3;//回到normal状态下的值，开始录制是1，完成了录制是2
//    _recordImage = nil;//保证下次再录制的时候得到下一次的第一张图片

}

- (void) H264Data: (Byte*) h264Frame length: (int) length type: (int) type timestamp: (NSInteger) timestamp
{
    //ULog(@"H264Data is %d",length);
 

}

-(void)ShowMainList:(id *)sender
{

    
    [self ActionForStopVideo:0 RemindFlag:1];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -视频开启
-(void)CameraTargetPressed{

    if ([appDelegate.appDefault objectForKey:@"Device_selected"] != nil)
    {
        
        appDelegate.m_PPPPChannelMgt->pCameraViewController = self;
        
        appDelegate.m_PPPPChannelMgt->ChangeStatusDelegate([[[appDelegate.appDefault objectForKey:@"Device_selected"]  objectForKey:@"device_id"]  UTF8String], self);
        NSLog(@"device id is %s",[[[appDelegate.appDefault objectForKey:@"Device_selected"]  objectForKey:@"device_id"]  UTF8String]);
        [self CameraSwitchPressed];
    }
    else
    {
        [self makeAlert:@"未选择看护器"];
    }
}

-(void)CameraSwitchPressed{
    
    if (_switchFlag == 0)
    {
        
        //检测网络状态
        Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
        
        if ([r currentReachabilityStatus] == NotReachable)
        {
            [self makeAlert:@"网络中断，请确认"];
            _wifiFlag = 0;
            return;
        }
        else if([r currentReachabilityStatus] == ReachableViaWWAN)
        {
            
            if (_wifiFlag == 0)
            {
                
                //[self makeAlert:@"检测到非WIFI网络，如有需要，请手动开启视频"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到非WIFI网络，确认开启视频吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认开启", nil];
                alert.tag = 100;
                [alert show];
                _wifiFlag = 1;
                return;
            }
            
        }
        else
        {
            _wifiFlag = 0;
        }
        
        //开启
        [self ShowCameraPlaying];
        
        
    }
    else
    {
        
        [self ActionForStopVideo:0 RemindFlag:1];
    }
}

-(void)ShowCameraPlaying{
    NSLog(@"ShowCameraPlaying");
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [appDelegate.appDefault setInteger:0 forKey:@"Last_page_flag"];

        NSLog(@"ShowCameraPlaying else");
    
        //选择的那个设备
        _currentDeviceDic=[appDelegate.appDefault objectForKey:@"Device_selected"];
        //先校验是否在线
        int result = appDelegate.m_PPPPChannelMgt->CheckOnlineReturn((char *)[[_currentDeviceDic objectForKey:@"device_id"] UTF8String]);
    
        if (result <= 0)
        { //不在线 或未连接，
            NSLog(@"device is not connected or is not online============");
            
            [self ConnectCamForUnEqual];
        }
        else if(result == 1)
        { //连接成功，检测账号密码。
            //发送检测账户指令？
            _finishFlag = 1; //代表连接成功
            _passwordFlag = 0;
            _stopConnectFlag = 0;
            NSLog(@"password 2 is %d",_passwordFlag);
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
            indicator.labelText = @"视频连接中";
            indicator.dimBackground = YES;
            //[self addTapGest:indicator];//单击的话会终止视频连接
            [self.view addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                //检验用户信息和密码
                appDelegate.m_PPPPChannelMgt->CheckUser((char *)[[_currentDeviceDic objectForKey:@"device_id"] UTF8String], (char *)[DeviceInitUser UTF8String], (char *)[[_currentDeviceDic objectForKey:@"pass"] UTF8String]);
                while (_finishFlag != 0 && _stopConnectFlag == 0)
                {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
            } completionBlock:^{
                [indicator removeFromSuperview];
                
                if (_stopConnectFlag != 0)
                {
                    _finishFlag = 0;
                    return;
                }
                
                if (_switchFlag == 1)
                {
                    //开始播放视频
                    [self ActionForStartVideo];
                }
                else if (_switchFlag == 0)
                {
                    
                    if ([_errorMsg length] == 0)
                    {
                        _errorMsg = @"看护器连接错误";
                    }
//                    [self makeAlert:_errorMsg];
                    
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"看护器连接错误，请重置看护器" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag=10010;
                    [alert show];

                }
            }];
            
        }
        else
        {
            
            NSLog(@"checkFinishFlag == 2");
            [appDelegate.appDefault setObject:_cameraID forKey:@"Last_device_id"];
            _cameraID = [_currentDeviceDic objectForKey:@"device_id"];
            _switchFlag = 1;
            [self ActionForStartVideo];
        }

}

//未连接或者不在线
- (void)ConnectCamForUnEqual{
    NSLog(@"ConnectCamForUnEqual");
    
    [_m_PPPPChannelMgtCondition lock];
    if (appDelegate.m_PPPPChannelMgt == NULL)
    {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    //每次都重新给last_device_id赋值
    _cameraID = [_currentDeviceDic objectForKey:@"device_id"];
    [appDelegate.appDefault setObject:_cameraID forKey:@"Last_device_id"];
    
    appDelegate.m_PPPPChannelMgt->Stop((char *)[_cameraID UTF8String]);
    
    dispatch_async(dispatch_get_main_queue(),^{
//        _playView.image = [UIImage imageNamed:@"cameraBackView.png"];
    });
    
//    [_currentDeviceDic addEntriesFromDictionary:[appDelegate.appDefault objectForKey:@"Device_selected"]];
    
    
    _finishFlag = 1;
    _passwordFlag = 0;
    _stopConnectFlag = 0;
    _errorMsg = @"看护器连接错误";
    NSLog(@"password 3 is %d",_passwordFlag);
    MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
    indicator.labelText = @"视频连接中";
    indicator.dimBackground = YES;
//    [self addTapGest:indicator];//点击终止视频
    [self.view addSubview:indicator];
    [indicator showAnimated:YES whileExecutingBlock:^{
        
        [self performSelector:@selector(startPPPP:) withObject:_currentDeviceDic];
        
        NSLog(@"stop connect Flag 222222222= [%d] [%d]", _finishFlag, _stopConnectFlag);
        
        while (_finishFlag != 0 && _stopConnectFlag == 0) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            
        }
    } completionBlock:^{
        [indicator removeFromSuperview];
        
        [_m_PPPPChannelMgtCondition unlock];
        
        sleep(0.1);
        
        if (_stopConnectFlag != 0) {
            _finishFlag = 0;
            return;
        }
        
        if (_switchFlag == 1)
        {
            [self ActionForStartVideo];

        }
        else if (_switchFlag == 0)
        {
            
            if (_errorFlag == 5)
            {
                
                _finishFlag = 1;
                _passwordFlag = 0;
                _stopConnectFlag = 0;
                NSLog(@"password 4 is %d",_passwordFlag);
                MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
                indicator.labelText = _errorMsg;
                indicator.dimBackground = YES;
               // [self addTapGest:indicator];
                [self.view addSubview:indicator];
                [indicator showAnimated:YES whileExecutingBlock:^{
                    
                    while (_finishFlag != 0 && _stopConnectFlag == 0)
                    {
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                    }
                } completionBlock:^{
                    [indicator removeFromSuperview];
                    
                }];
                
                while (_finishFlag != 0 && _stopConnectFlag == 0)
                {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
                
                if (_stopConnectFlag != 0)
                {
                    _finishFlag = 0;
                    return;
                }
                
                if (_switchFlag == 1)
                {
                    [self ActionForStartVideo];

                    
                }else{
//                    [self makeAlert:_errorMsg];
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"看护器连接错误，请重置看护器" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag=10086;
                    [alert show];
                    
                }
            }else{
                if ([_errorMsg length] == 0) {
                    _errorMsg = @"看护器连接错误";
                }
//                [self makeAlert:_errorMsg];
                
               
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"看护器连接错误，请重置看护器" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag=10000;
                [alert show];
            }
        }
        
    }];
}

-(void)startPPPP:(NSDictionary *)device{
    appDelegate.m_PPPPChannelMgt->Start([[device objectForKey:@"device_id"] UTF8String], (char *)[DeviceInitUser UTF8String],[[device objectForKey:@"pass"] UTF8String]);
}

-(void)startVideo{
    if (appDelegate.m_PPPPChannelMgt != NULL)
    {
        if (appDelegate.m_PPPPChannelMgt->StartPPPPLivestream([_cameraID UTF8String], 10, self) == 0)
        {
            appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
            appDelegate.m_PPPPChannelMgt->StopPPPPLivestream([_cameraID UTF8String]);
            return;
        }
    }
}

-(void)stopVideo{
    if (appDelegate.m_PPPPChannelMgt != NULL) {
        appDelegate.m_PPPPChannelMgt->StopPPPPLivestream([_cameraID UTF8String]);
    }
}


#pragma mark -PPPPStatusDelegate
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status
{
    NSString* strPPPPStatus;
    switch (status)
    {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnecting", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInitialing", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectFailed", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusDisconnected", @STR_LOCALIZED_FILE_NAME, nil);
            if(_finishFlag != 1 && _switchFlag == 1)
            {
                //视频播放中 连接失败
                [self performSelectorOnMainThread:@selector(CameraDisconnect) withObject:nil waitUntilDone:YES];
            }
            
            break;
        case PPPP_STATUS_INVALID_ID:
            NSLog(@"PPPP_STATUS_INVALID_ID");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvalidID", @STR_LOCALIZED_FILE_NAME, nil);
            if (_finishFlag == 1) {
                _errorFlag = 1; //序列号错误
                _errorMsg = @"看护器序列号错误";
                [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
            }
            break;
        case PPPP_STATUS_ON_LINE:
            NSLog(@"PPPP_STATUS_ON_LINE");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusOnline", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            NSLog(@"PPPP_STATUS_DEVICE_NOT_ON_LINE");
            strPPPPStatus = NSLocalizedStringFromTable(@"CameraIsNotOnline", @STR_LOCALIZED_FILE_NAME, nil);
            if (_finishFlag == 1) {
                _errorFlag = 2;
                _errorMsg = @"看护器不在线";
                [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
            }
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            NSLog(@"time out===============================");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectTimeout", @STR_LOCALIZED_FILE_NAME, nil);
            if (_finishFlag == 1) {
                _errorFlag = 3;
                _errorMsg = @"看护器连接超时";
                [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
            }
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            NSLog(@"PPPP_STATUS_INVALID_USER_PWD");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusInvaliduserpwd", @STR_LOCALIZED_FILE_NAME, nil);
            
            //校验密码是否为初始密码，如果不是，用初始密码重新连接
            if (![[_currentDeviceDic objectForKey:@"pass"] isEqualToString:DeviceInitPass])
            {
                NSLog(@"passwordFlag is5 %d",_passwordFlag);
                
                if (_passwordFlag != 1)
                {
                    _passwordFlag = 1;
                    //校验密码
                   appDelegate.m_PPPPChannelMgt->CheckUser((char *)[_cameraID UTF8String], (char *)[DeviceInitUser UTF8String], (char *)[DeviceInitPass UTF8String]);
                    NSLog(@"password 6 is %d",_passwordFlag);
                }
                else
                {
                    NSLog(@"password 7 is %d",_passwordFlag);

                    _errorFlag = 4;
                    _errorMsg = @"看护器连接错误，请重置看护器";
                    [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
                }
            }
            else
            {
                _errorFlag = 4;
                _errorMsg = @"看护器账号连接错误，请重置看护器";
                [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
                
            }
            
            break;
        case PPPP_STATUS_VALID_USER_PWD:
            NSLog(@"PPPP_STATUS_VALID_USER_PWD");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPP_STATUS_VALID_USER_PWD", @STR_LOCALIZED_FILE_NAME, nil);
            //校验密码是否为初始密码，如果是，修改密码 -- 可放置在对象中完成
            if (![[_currentDeviceDic objectForKey:@"pass"] isEqualToString:DeviceInitPass])
            {
                if (_passwordFlag == 1)
                {
                    
                    NSLog(@"password 8 is %d",_passwordFlag);
                    //修改密码
                    appDelegate.m_PPPPChannelMgt->SetUserPwdForOther((char *)[_cameraID UTF8String], (char *)[DeviceInitUser UTF8String], (char *)[DeviceInitPass UTF8String]);
                    
                    //重启看护器
                    appDelegate.m_PPPPChannelMgt->RebootDevice((char *)[_cameraID UTF8String], (char *)[DeviceInitUser UTF8String], (char *)[DeviceInitPass UTF8String]);
                    
                    _errorFlag = 5;
                    _errorMsg = @"看护器重启中,\n请等待";
                    [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
                    
                }
                else
                {
                    
                    appDelegate.m_PPPPChannelMgt->SetOnlineFlag((char *)[_cameraID UTF8String], 2);
                    
                    
                    if ([[[[appDelegate.appDefault objectForKey:@"Device_selected"] objectForKey:@"id_member"] stringValue] isEqualToString:@"1"])
                    {
                        
                    if ([appDelegate.appDefault objectForKey:_cameraID] == nil)
                    {
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"512", @"quality", @"0", @"sense",@"0",@"inputSense", nil];
                        [appDelegate.appDefault setObject:dic  forKey:_cameraID];
                    }
                        
                    }
                    [self performSelectorOnMainThread:@selector(Finish:) withObject:@"1" waitUntilDone:NO];

                    
                   
                    
                    //设置视频质量
                    appDelegate.m_PPPPChannelMgt->CameraControl( (char *)[_cameraID UTF8String],13, [[[appDelegate.appDefault objectForKey:_cameraID] objectForKey:@"quality"] integerValue]);
                    
                    
                    if ([[[[appDelegate.appDefault objectForKey:@"Device_selected"] objectForKey:@"id_member"] stringValue] isEqualToString:@"1"])
                    {
                        appDelegate.m_PPPPChannelMgt->SetAlarmDelegate((char *)[_cameraID UTF8String],appDelegate);
                        //移动侦测回调接收
                        appDelegate.m_PPPPChannelMgt->SetSensorAlarmDelegate((char *)[_cameraID UTF8String],appDelegate);
                        //设置移动侦测
                        appDelegate.m_PPPPChannelMgt->SetAlarm((char *)[_cameraID UTF8String],[[[appDelegate.appDefault objectForKey:_cameraID] objectForKey:@"sense"] integerValue], 1, [[[appDelegate.appDefault objectForKey:_cameraID] objectForKey:@"inputSense"] integerValue], 0, 0, 1, 0, 0, 0, 0);
                    }
                }
            }
            else
            {
                //生成随机数，修改密码
                int randInt = [[_currentDeviceDic objectForKey:@"pass"] integerValue];
                while (randInt == [[_currentDeviceDic objectForKey:@"pass"] integerValue])
                {
                    randInt = [self getRandomNumber:100000 to:999999];
                }
//                randInt = 888888;
                
                //通知服务器密码已修改
                BOOL result = [appDelegate.webInfoManger UserModifyDevicePasswordUsingToken:[appDelegate.appDefault objectForKey:@"Token"] DeviceId:_cameraID DeviceUser:[_currentDeviceDic objectForKey:@"name"] DevicePasswd:[NSString stringWithFormat:@"%d", randInt]];
                
                if (result) {
                    //修改密码
                    appDelegate.m_PPPPChannelMgt->SetUserPwd((char *)[_cameraID UTF8String], (char *)"", (char *)"", (char *)"", (char *)"", (char *)[[_currentDeviceDic objectForKey:@"name"] UTF8String], (char *)[[NSString stringWithFormat:@"%d", randInt] UTF8String]);
                    
                    //设置devicelist
                    [appDelegate.deviceConnectManager modifyDevicePassword:_cameraID Password:[NSString stringWithFormat:@"%d", randInt]];
                    [_currentDeviceDic addEntriesFromDictionary:[appDelegate.deviceConnectManager getDeviceInfo:_cameraID]];
                    
//                    NSLog(@"current device = [%@][%@]",_currentDeviceDic, [appDelegate.deviceConnectManager getDeviceInfo:_cameraID]);
                    
                    //重启看护器
                    appDelegate.m_PPPPChannelMgt->PPPPSetSystemParams((char *)[_cameraID UTF8String], MSG_TYPE_REBOOT_DEVICE, nil, 0);
                    
                    //重设账户密码
                    appDelegate.m_PPPPChannelMgt->SetUserAndPwd((char *)[_cameraID UTF8String], (char *)[DeviceInitUser UTF8String], (char *)[[NSString stringWithFormat:@"%d", randInt] UTF8String]);
                    
                    _errorFlag = 5;
                    _errorMsg = @"看护器重启中,\n请等待";
                    [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
                }else{
                    _errorFlag = 6;
                    _errorMsg = @"设备连接错误";
                    [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
                }
            }
            break;
        case PPPP_STATUS_CONNECT_SUCCESS:
            NSLog(@"PPPP_STATUS_CONNECT_SUCCESS, manager = [%@]", self);
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusConnectSuccess", @STR_LOCALIZED_FILE_NAME, nil);
            break;
        default:
            NSLog(@"PPPPStatusUnknown");
            strPPPPStatus = NSLocalizedStringFromTable(@"PPPPStatusUnknown", @STR_LOCALIZED_FILE_NAME, nil);
            [self performSelectorOnMainThread:@selector(Finish:) withObject:@"0" waitUntilDone:NO];
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
}
#pragma mark -
#pragma mark PPPPSensorAlarmDelegate
- (void) PPPPSensorAlarm:(NSString*) strDid andSensorInfo:(STRU_SENSOR_ALARM_INFO)  sensorInfo{
    int cmd = sensorInfo.cmd;
    
    switch (cmd) {
        case ALARM_MOTION_INFO:
        {
            //移动侦测 具体实现
            NSLog(@"移动侦测调用、、、、、、、、、、、、、、、、、、、、、、、");
        }
            break;
    }
    
}

-(void)CameraDisconnect{
    
    [self ActionForStopVideo:0 RemindFlag:0];
    
    [self makeAlert:@"看护器连接断开，请确认"];
}

-(void)Finish:(NSString *)flag{
    if (_finishFlag == 0) {
        _switchFlag = 0;
    }else{
        _finishFlag = 0;
        _switchFlag = [flag integerValue];

    }
}

//刷新视频图片
- (void) refreshImage:(UIImage* )image{
    if (image != nil) {
        dispatch_async(dispatch_get_main_queue(),^{
//            _playView.image = image;
        });
    }
}

//增加手势,旋转摄像头
-(void) imageAddGest:(UIView *)view
{
    UISwipeGestureRecognizer *recognizer;
    view.userInteractionEnabled = YES;  //使图片的手势可用
    
    /*********************** 图片的上下左右手势 *************************/
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [view addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [view addGestureRecognizer:recognizer];
    
    //横屏单击
    UITapGestureRecognizer *taprecognizer;
    taprecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(operToolBar:)];
    taprecognizer.numberOfTapsRequired = 1;
    [view addGestureRecognizer:taprecognizer];
    
}

-(void)operToolBar:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTapsRequired == 1) {
        if (_orientationFlag == 1) {
            
            NSLog(@"operToolBar");
            //触发显示或隐藏工具栏事件
            if (_toolBarHiddenFlag == 0) {
                NSLog(@"hideToolBar");
                
                [self hideToolBar];
            }else{
                [self showToolBar];
                NSLog(@"showToolBar");
                
            }
        }
    }
}

-(void)showToolBar{

    _toolBarHiddenFlag = 0;
    
    
    //开启收听功能后，不主动隐藏工具栏
    if (_listenFlag == 0) {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideToolBar) userInfo:nil repeats:YES];
    }
    
    [UIView animateWithDuration:0.6 animations:^{
        [self.view viewWithTag:2010].frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 52);
        [self.view viewWithTag:102].frame = CGRectMake(0, 268, [UIScreen mainScreen].bounds.size.height, 52);
        self.view.userInteractionEnabled = NO;
    }completion:^(BOOL finished){
        self.view.userInteractionEnabled = YES;
    }];

}

-(void)hideToolBar{
    
    if (_hiddenTimer) {
        [_hiddenTimer invalidate];
        _hiddenTimer = nil;
    }
    
    if (_toolBarHiddenFlag == 1) {
        return;
    }
    
    if (_switchFlag == 0 || _talkFlag == 1 || _touchFlag == 1) {
        return;
    }
    
    NSLog(@"hidetoolbar=========1");
    
    _toolBarHiddenFlag = 1;
    
    [UIView animateWithDuration:0.6 animations:^{
        [self.view viewWithTag:2010].frame = CGRectMake(0, -52, [UIScreen mainScreen].bounds.size.height, 52);
        [self.view viewWithTag:102].frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.height, 52);
        self.view.userInteractionEnabled = NO;
    }completion:^(BOOL finished){
        self.view.userInteractionEnabled = YES;
    }];
}

//手势不同执行不同的方法旋转摄像头
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        appDelegate.m_PPPPChannelMgt->PTZ_Control([_cameraID UTF8String], CMD_PTZ_UP);
    }
    else if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        appDelegate.m_PPPPChannelMgt->PTZ_Control([_cameraID UTF8String], CMD_PTZ_DOWN);
    }
    else if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        appDelegate.m_PPPPChannelMgt->PTZ_Control([_cameraID UTF8String], CMD_PTZ_RIGHT);
    }
    else if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        appDelegate.m_PPPPChannelMgt->PTZ_Control([_cameraID UTF8String], CMD_PTZ_LEFT);
    }
}

-(void)rotateToOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _playView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.height - 426)/2, 0, 426, 320);
        [self.navigationController setNavigationBarHidden:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        self.view.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0];
        
        _lockFlag = 0;
        _orientationFlag = 1;
        _toolBarHiddenFlag = 1;
        
        [self.view viewWithTag:11].hidden = YES;
        [self.view viewWithTag:101].hidden = YES;
        [self.view viewWithTag:102].hidden = NO;
        [self.view viewWithTag:102].frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.height, 52);
        
        //_snapImageView.hidden = YES;
        [self.view viewWithTag:2010].hidden = NO;
        [self.view viewWithTag:2010].frame = CGRectMake(0, -52, [UIScreen mainScreen].bounds.size.height, 52);
        
    }else if(toInterfaceOrientation == UIInterfaceOrientationPortrait){
        _playView.frame = CGRectMake(0, 0, 320, 240);
        [self.navigationController setNavigationBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        self.view.backgroundColor = [UIColor whiteColor];
        
        _lockFlag = 0;
        _orientationFlag = 0;
        
        [self.view viewWithTag:11].hidden = NO;
        [self.view viewWithTag:101].hidden = NO;
        [self.view viewWithTag:102].hidden = YES;
        
        //_snapImageView.hidden = NO;
        [self.view viewWithTag:2010].hidden = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    _rotateEnableFlag = 1;
    _lockFlag = 0;
    [_lockButton setImage:[UIImage imageNamed:@"lock_off.png"] forState:UIControlStateNormal];
    [_lockButton setImage:[UIImage imageNamed:@"lock_off_highlighted.png"] forState:UIControlStateHighlighted];
   
    [self CameraTargetPressed];
    [self.collectionView reloadData];

}
- (void)viewWillAppear:(BOOL)animated
{
    [self titleSet:[[appDelegate.appDefault objectForKey:@"Device_selected"] objectForKey:@"name"]];
    _isViode = FALSE;
    
    if (_isScreen) {
        self.navigationController.navigationBarHidden=YES;
    }
    
    if ([[appDelegate.appDefault objectForKey:[ _currentDeviceDic objectForKey:@"device_id"]] objectForKey:@"invert"])
    {
        
        NSLog(@"函数里面");
        int invert = [[[appDelegate.appDefault objectForKey:[ _currentDeviceDic objectForKey:@"device_id"]] objectForKey:@"invert"] integerValue];
        if (invert == 1)
        {
            _playView.transform = CGAffineTransformMakeRotation(M_PI);

        }

        
    }
//    if ([[[appDelegate.appDefault objectForKey:[ _currentDeviceDic objectForKey:@"device_id"]] objectForKey:@"sense"] integerValue])
//    {
//        int alerm =[[[appDelegate.appDefault objectForKey:[ _currentDeviceDic objectForKey:@"device_id"]] objectForKey:@"sense"] integerValue];
//        if (alerm == 1)
//        {
//            AudioServicesPlaySystemSound(1007);
//            
//        }
//    }
    NSLog(@"视图出现");
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{

    [self.collectionView reloadData];
    //视频倒置复原
    int invert = [[[appDelegate.appDefault objectForKey:[ _currentDeviceDic objectForKey:@"device_id"]] objectForKey:@"invert"] integerValue];
    if (invert == 1)
    {
        _playView.transform = CGAffineTransformRotate(_playView.transform, -M_PI);
    }
    
}
-(void)viewDidDisappear:(BOOL)animated{
   

    NSLog(@"viewDidDisappear");
    if (_switchFlag == 0) {
        return;
    }
    
    if (_listenFlag == 1) {
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        _listenFlag = 0;
    }else if(_talkFlag == 1){
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        _talkFlag = 0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
   
}

-(void)ActionForStopVideo:(int)photoDeleteFlag RemindFlag:(int)remindFlag{
    
    [self stopVideo];
    _switchFlag = 0;
    if (_listenFlag == 1)
    {
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        _listenFlag = 0;
    }
    else if(_talkFlag == 1)
    {
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        _talkFlag = 0;
    }
    
    if (remindFlag == 1)
    {
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
        indicator.labelText = @"视频关闭";
        indicator.mode = MBProgressHUDModeText;
        [self.view addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];

            
            [self ActionForResetButton];
            
        }];
    }
    else
    {
        
        [self ActionForResetButton];
        
        if (photoDeleteFlag == 1)
        {
            
        }
    }
    
    
}

-(void)ActionForResetButton
{
    UIImageView *imageView = (UIImageView *)[self.navigationItem.titleView viewWithTag:20];
    [imageView setImage:[UIImage imageNamed:@"switch_off.png"]];
    [(UIButton *)[self.view viewWithTag:2020] setImage:[UIImage imageNamed:@"vertical_switch_off.png"] forState:UIControlStateNormal];
    [(UIButton *)[self.view viewWithTag:2020] setImage:[UIImage imageNamed:@"vertical_switch_off_highlighted.png"] forState:UIControlStateHighlighted];
//    _playView.image = [UIImage imageNamed:@"cameraBackView.png"];
    
    //竖屏工具条
    ((UIButton *)[self.view viewWithTag:1]).enabled = NO;
    ((UIButton *)[self.view viewWithTag:2]).enabled = NO;
    ((UIButton *)[self.view viewWithTag:3]).enabled = NO;
    //[(UIButton *)[self.view viewWithTag:3] setImage:[UIImage imageNamed:@"callButton.png"] forState:UIControlStateNormal];
    
    //横屏工具条
    ((UIButton *)[self.view viewWithTag:2001]).enabled = NO;
    ((UIButton *)[self.view viewWithTag:3001]).enabled = NO;
    [(UIButton *)[self.view viewWithTag:3001] setImage:[UIImage imageNamed:@"vertical_callButton.png"] forState:UIControlStateNormal];
    [(UIButton *)[self.view viewWithTag:3001] setImage:[UIImage imageNamed:@"vertical_callButton_highlighted.png"] forState:UIControlStateHighlighted];
}

-(void)ActionForStartVideo{
    
    
    self.navigationItem.leftBarButtonItem.enabled=YES;
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
    
    
    [self startVideo];
    //开启定时隐藏工具栏任务
    if (_orientationFlag == 1)
    {
        _hiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideToolBar) userInfo:nil repeats:YES];
    }
    
    MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithView:self.view];
    indicator.labelText = @"视频开启";
    indicator.mode = MBProgressHUDModeText;
    [self.view addSubview:indicator];
    [indicator showAnimated:YES whileExecutingBlock:^{
        sleep(1.2);
    } completionBlock:^{
        [indicator removeFromSuperview];
        

        
        UIImageView *imageView = (UIImageView *)[self.navigationItem.titleView viewWithTag:20];
        [imageView setImage:[UIImage imageNamed:@"switch_on.png"]];
        [(UIButton *)[self.view viewWithTag:2020] setImage:[UIImage imageNamed:@"vertical_switch_on.png"] forState:UIControlStateNormal];
        [(UIButton *)[self.view viewWithTag:2020] setImage:[UIImage imageNamed:@"vertical_switch_off_highlighted.png"] forState:UIControlStateHighlighted];
        ((UIButton *)[self.view viewWithTag:1]).enabled = YES;
        if ([appDelegate.appDefault integerForKey:@"Relative_login_flag"] == 0) {
            ((UIButton *)[self.view viewWithTag:2]).enabled = YES;
            ((UIButton *)[self.view viewWithTag:2001]).enabled = YES;
            ((UIButton *)[self.view viewWithTag:3]).enabled = YES;
            ((UIButton *)[self.view viewWithTag:3001]).enabled = YES;
            
        }else{
            if ([appDelegate.appDefault integerForKey:@"Relative_listen_flag"] == 1) {
                ((UIButton *)[self.view viewWithTag:2]).enabled = YES;
                ((UIButton *)[self.view viewWithTag:2001]).enabled = YES;
                ((UIButton *)[self.view viewWithTag:3]).enabled = YES;
                ((UIButton *)[self.view viewWithTag:3001]).enabled = YES;
                
            }
        }
        
        if (_orientationFlag == 1) {
            [self hideToolBar];
        }
        
    }];
}


-(void)GoBackground:(NSNotification *)notification
{
    
    NSLog(@"GoBackground=====================");
    dispatch_async(dispatch_get_main_queue(),^{
        
        
        
        if (_hiddenTimer) {
            [_hiddenTimer invalidate];
            _hiddenTimer = nil;
        }
        
        _toolBarHiddenFlag = 0;
        
        [self.view viewWithTag:102].frame = CGRectMake(0, 268, [UIScreen mainScreen].bounds.size.height, 52);
        [self.view viewWithTag:2010].frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 52);
        

//        _playView.image = [UIImage imageNamed:@"cameraBackView.png"];
        
        //竖屏工具栏
        ((UIButton *)[self.view viewWithTag:1]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:2]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:3]).enabled = NO;
        
        //横屏工具栏
        ((UIButton *)[self.view viewWithTag:2001]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:3001]).enabled = NO;
        _switchFlag = 0;
        _listenFlag = 0;
        _talkFlag = 0;
        //[_imageArray removeAllObjects];
        //[_collectionImageArray removeAllObjects];
        _photoCount = 0;
        //[_snapImageView removeFromSuperview];
        
        if (_isRecord ==1)
        {
            _isRecord = 2;
            [(UIButton *)[_lView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
            [(UIButton *)[_lTalkView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
        }
        
        
        
    });
    
}
-(void)WillResignActive:(NSNotification *)nitification
{
    

    dispatch_async(dispatch_get_main_queue(),^{
    if (_hiddenTimer) {
            [_hiddenTimer invalidate];
            _hiddenTimer = nil;
        }
        
        _toolBarHiddenFlag = 0;
        
        [self.view viewWithTag:102].frame = CGRectMake(0, 268, [UIScreen mainScreen].bounds.size.height, 52);
        [self.view viewWithTag:2010].frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 52);
        
        
        //        _playView.image = [UIImage imageNamed:@"cameraBackView.png"];
        
        //竖屏工具栏
        ((UIButton *)[self.view viewWithTag:1]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:2]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:3]).enabled = NO;
        
        //横屏工具栏
        ((UIButton *)[self.view viewWithTag:2001]).enabled = NO;
        ((UIButton *)[self.view viewWithTag:3001]).enabled = NO;
        _switchFlag = 0;
        _listenFlag = 0;
        _talkFlag = 0;
        //[_imageArray removeAllObjects];
        //[_collectionImageArray removeAllObjects];
        _photoCount = 0;
        //[_snapImageView removeFromSuperview];
        
        if (_isRecord ==1)
        {
            _isRecord = 2;
            //[btn1 setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
            [(UIButton *)[_lView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
            [(UIButton *)[_lTalkView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
        }
        
        
        
    });

    
}

-(void)becameActive:(NSNotification *)nitification
{
    
    _isRecord = 3;
    _switchFlag = 0;
    _isStart = false;
    _recordImage = nil;
    [_imageArray removeAllObjects];
    [self.collectionImageArray removeAllObjects];
    [self.collectionView reloadData];
    [(UIButton *)[_lView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
    [(UIButton *)[_pView viewWithTag:2] setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];

    
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"hasComeBackFromBackground"];

    _isViode = FALSE;
    
    [_lView viewWithTag:13].hidden = NO;
    [_lView viewWithTag:14].hidden = YES;
    [_lView viewWithTag:15].hidden = YES;
    
    
    [_lTalkView viewWithTag:13].hidden = NO;
    [_lTalkView viewWithTag:14].hidden = YES;
    [_lTalkView viewWithTag:15].hidden = YES;
    
    if ([self.view window] != nil)
    {
        [self CameraTargetPressed];
    }

}

- (void)pop:(UIButton *)button
{
    if(_isRecord==1)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在录制，是否保存?" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"不保存", nil];
        alert.tag =11111;
        [alert show];
    }
    else
    {
        [self ActionForStopVideo:0 RemindFlag:1];
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
            _talkFlag = 0;
     
        [self.navigationController popViewControllerAnimated:YES];
    }
}


//摄像头设置
- (void)cameraSettings:(UIBarButtonItem *)item
{
    if(_isRecord==1)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:@"正在录制，是否保存?" delegate:self cancelButtonTitle:@"保存" otherButtonTitles:@"不保存", nil];
        alert.tag =22222;
        [alert show];
    }
    else
    {
        
        
        _isViode = FALSE;
        _isStart = false;

        [self ActionForStopVideo:0 RemindFlag:1];
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        _talkFlag = 0;
        _recordImage = nil;
        
        [_lTalkView viewWithTag:13].hidden = NO;
        [_lTalkView viewWithTag:14].hidden = YES;
        [_lTalkView viewWithTag:15].hidden = YES;

        
        
        CameraSettingViewController *vc = [[CameraSettingViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
#pragma mark alertViewDelegate
#pragma mark alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            [self ShowCameraPlaying];
        }
        
    }
    if (alertView.tag==10010) {
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (alertView.tag==10086) {
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if (alertView.tag==10000) {
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if (alertView.tag==777) {
        if (buttonIndex==0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    if(alertView.tag ==22222 || alertView.tag == 33333)
    {
        _isRecord =3;
        _isStart = false;
        _recordImage = nil;

        [self ActionForStopVideo:0 RemindFlag:1];
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        _talkFlag = 0;

        [_lView viewWithTag:13].hidden = NO;
        [_lView viewWithTag:14].hidden = YES;
        [_lView viewWithTag:15].hidden = YES;
        
        
        [_lTalkView viewWithTag:13].hidden = NO;
        [_lTalkView viewWithTag:14].hidden = YES;
        [_lTalkView viewWithTag:15].hidden = YES;

        UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
        
        UIButton *btn2 = (UIButton *)[_lView viewWithTag:2];
        [btn2 setBackgroundImage:[UIImage imageNamed:@"切图_04.png"] forState:UIControlStateNormal];
        
       
        
        if(buttonIndex ==0)
        {
            [self savePicAndVideo];
            
            if (alertView.tag == 33333)
            {
                self.navigationController.navigationBarHidden=NO;
                SharedPersonsViewController *sharedPersonVC = [[SharedPersonsViewController alloc] initWithDeviceID:[_currentDeviceDic objectForKey:@"device_id"]];
                //添加状态栏
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                [self.navigationController pushViewController:sharedPersonVC animated:YES];
            }
            else if(alertView.tag ==22222)
            {
                CameraSettingViewController *vc = [[CameraSettingViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            
            }
            

        }
        else
        {
            NSFileManager * manager =[[NSFileManager alloc] init];
            NSError*err;
            if(![manager removeItemAtPath:vedioPath error:&err])
            {
                NSLog(@"%@",err);
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",err] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                NSLog(@"删除视频成功!");
                NSError *err1;
                
                if (![manager removeItemAtPath:imagePath1 error:&err1])
                {
                    NSLog(@"%@",err1);
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",err1] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }
                else
                {
                    [appDelegate.sqliteManager removeRecordInfo:[insertDict1 objectForKey:@"id_record"] deleteType:1];
                    [self.collectionImageArray removeLastObject];
                    [self.collectionView reloadData];
                    if (alertView.tag == 33333)
                    {
                        self.navigationController.navigationBarHidden=NO;
                        SharedPersonsViewController *sharedPersonVC = [[SharedPersonsViewController alloc] initWithDeviceID:[_currentDeviceDic objectForKey:@"device_id"]];
                        [self.navigationController pushViewController:sharedPersonVC animated:YES];
                    }
                    else if(alertView.tag ==22222)
                    {
                        CameraSettingViewController *vc = [[CameraSettingViewController alloc]init];
                        [self.navigationController pushViewController:vc animated:YES];
                        
                    }
                }
                
            }
        }
    }
    
    if(alertView.tag ==11111)
    {
        UIButton *btn1 = (UIButton *)[_pView viewWithTag:2];
        [btn1 setBackgroundImage:[UIImage imageNamed:@"切图_55.png"] forState:UIControlStateNormal];
        
         _isRecord =3;
        _isViode = FALSE;
        _isStart = false;
        [self ActionForStopVideo:0 RemindFlag:1];
        appDelegate.m_PPPPChannelMgt->StopPPPPAudio([_cameraID UTF8String]);
        appDelegate.m_PPPPChannelMgt->StopPPPPTalk([_cameraID UTF8String]);
        _talkFlag = 0;
        
        [_lView viewWithTag:13].hidden = NO;
        [_lView viewWithTag:14].hidden = YES;
        [_lView viewWithTag:15].hidden = YES;
        
        
        [_lTalkView viewWithTag:13].hidden = NO;
        [_lTalkView viewWithTag:14].hidden = YES;
        [_lTalkView viewWithTag:15].hidden = YES;

        
        if(buttonIndex ==0)
        {
            [self savePicAndVideo];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {

            NSFileManager * manager =[[NSFileManager alloc] init];
            NSError*err;
            if(![manager removeItemAtPath:vedioPath error:&err])
            {
                NSLog(@"%@",err);
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",err] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                NSLog(@"删除视频成功!");
                NSError *err1;
                
                if (![manager removeItemAtPath:imagePath1 error:&err1])
                {
                    NSLog(@"%@",err1);
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",err1] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                }
                else
                {
                [appDelegate.sqliteManager removeRecordInfo:[insertDict1 objectForKey:@"id_record"] deleteType:1];
                [self.collectionImageArray removeLastObject];
                [self.collectionView reloadData];
                [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }
}
#pragma mark -
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.collectionImageArray.count;
    NSLog(@"数量是%d",self.collectionImageArray.count);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:REUSEABLE forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ITEM_WIDTH, ITEM_HEIGTH)];
    imageView.userInteractionEnabled = YES;
    imageView.image = [self.collectionImageArray objectAtIndex:indexPath.row];
    cell.bounds=CGRectMake(0, 0, ITEM_WIDTH, ITEM_HEIGTH);

    //如果是视频图片，就要加一个类似于播放按钮
    if ([[[_imageArray objectAtIndex:indexPath.row] objectForKey:@"is_vedio"] intValue] == 1)
    {
        
        UIImageView *startImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start1.png"]];
        startImage.frame = CGRectMake(16, 2, 32, 32);
        [imageView addSubview:startImage];
        
    }
    [cell addSubview:imageView];

    return cell;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    
    _currentPage = indexPath.row;
    [self viewAddGest:[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath]];
}





@end
