//
//  AVCallController.m
//  BabyWith
//
//  Created by laoniu on 14-8-1.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "AVCallController.h"
#import "UIViewController+Alert.h"
#import "ImageShowController.h"
#import "MBProgressHUD.h"
#import "MainAppDelegate.h"

@interface AVCallController ()

@end

@implementation AVCallController
@synthesize avCaptureSession;
@synthesize labelState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    if(self= [super init])
    {
        firstFrame= YES;
        producerFps= 50;
        _imageArray = [[NSMutableArray alloc] init];
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    [self createControl];
}




/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark createControl
- (void)createControl
{
    //UI展示
    localView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:localView];
    [localView release];
    
    
    UIImage *deviceImage = [UIImage imageNamed:@"拍照1.png"];
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deviceBtn setBackgroundImage:deviceImage forState:UIControlStateNormal];
    [deviceBtn addTarget:self action:@selector(swapFrontAndBackCameras:)
        forControlEvents:UIControlEventTouchUpInside];
    [deviceBtn setFrame:CGRectMake(250, 20, 60, 30)];
    [self.view addSubview:deviceBtn];
    
    
    UIView *overlyView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-65, 320, 65)];
    [overlyView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"拍照5.png"]]];
    
    [self.view addSubview:overlyView];
    
    UIButton *cameraBtn;
    UIButton *photoBtn;
    
    //添加拍照时候的缩小图片
    SaveImage=[[UIImageView alloc] init];
    SaveImage.userInteractionEnabled=YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
    [SaveImage addGestureRecognizer:singleTap];

        SaveImage.frame=CGRectMake(25, 15, 50, 50);
    
    SaveImage.hidden=YES;
    [overlyView addSubview:SaveImage];
    
    cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame=CGRectMake(self.view.frame.size.width/2-80/2, 10, 80, 45);
    
    imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame=CGRectMake(25, 10, 40, 50);
    
    photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame=CGRectMake(260,15, 40, 40);
    
    [imageButton setBackgroundImage:[UIImage imageNamed:@"拍照2.png"] forState:UIControlStateNormal];
    [imageButton setBackgroundImage:[UIImage imageNamed:@"拍照2.png"] forState:UIControlStateHighlighted];
    [imageButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    imageButton.tag = 10;
    [overlyView addSubview:imageButton];
    
    
    [cameraBtn setImage:[UIImage imageNamed:@"拍照3.png"] forState:UIControlStateNormal];
    [cameraBtn setImage:[UIImage imageNamed:@"拍照3.png"] forState:UIControlStateHighlighted];
    [cameraBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    cameraBtn.tag = 20;
    [overlyView addSubview:cameraBtn];
    //        [cameraBtn release];
    
    
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"拍照4.png"] forState:UIControlStateNormal];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"拍照4.png"] forState:UIControlStateHighlighted];
    photoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    photoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    photoBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    photoBtn.tag = 30;
    [photoBtn addTarget:self action:@selector(showPhoto) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:photoBtn];

    isBackFront = TRUE;
    //显示视图
    [self startVideoCapture];
    isStop = false;
    
}
#pragma mark -
#pragma mark VideoCapture

//前置后置摄像头切换
-(void)swapFrontAndBackCameras:(id)sender
{
    isBackFront = !isBackFront;
    [self stopVideoCapture];
    [self startVideoCapture];
}
//拍照
-(void)takePicture
{
    //从budle路径下读取音频文件　　轻音乐 - 萨克斯回家 这个文件名是你的歌曲名字,mp3是你的音频格式
    NSString *string = [[NSBundle mainBundle] pathForResource:@"1374" ofType:@"wav"];
    //把音频文件转换成url格式
    NSURL *url = [NSURL fileURLWithPath:string];
    //初始化音频类 并且添加播放文件
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    //设置音乐播放次数  -1为一直循环
    _avAudioPlayer.numberOfLoops = 1;
    
    [_avAudioPlayer play];

    isStop = TRUE;
    imageButton.hidden = YES;
    SaveImage.hidden = NO;
}

- (AVCaptureDevice *)getFrontCamera
{
    //获取前置摄像头设备
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if(isBackFront)
        {
            if (device.position == AVCaptureDevicePositionBack)
                return device;
        }
        else
        {
            if (device.position == AVCaptureDevicePositionFront)
                return device;
        }
        
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
}
- (void)startVideoCapture
{
    //打开摄像设备，并开始捕抓图像
    [labelState setText:@"Starting Video stream"];
    if(self->avCaptureDevice|| self->avCaptureSession)
    {
        [labelState setText:@"Already capturing"];
        return;
    }
    
    if((self->avCaptureDevice = [self getFrontCamera]) == nil)
    {
        [labelState setText:@"Failed to get valide capture device"];
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput)
    {
        [labelState setText:@"Failed to get video input"];
        self->avCaptureDevice= nil;
        return;
    }
    

    
    self->avCaptureSession = [[AVCaptureSession alloc] init];
    self->avCaptureSession.sessionPreset = AVCaptureSessionPresetHigh;
    [self->avCaptureSession addInput:videoInput];
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.
    // On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
    //
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary*settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                             [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
//                             [NSNumber numberWithInt:self.view.frame.size.width], (id)kCVPixelBufferWidthKey,
//                             [NSNumber numberWithInt:self.view.frame.size.height], (id)kCVPixelBufferHeightKey,
                             nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    [settings release];
//    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, self->producerFps);
    
    /*We create a serial queue to handle the processing of our frames*/
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [self->avCaptureSession addOutput:avCaptureVideoDataOutput];
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self->avCaptureSession];
    previewLayer.frame = localView.bounds;
    previewLayer.videoGravity= AVLayerVideoGravityResizeAspectFill;
    
    [self->localView.layer addSublayer: previewLayer];
    
    self->firstFrame= YES;
    [self->avCaptureSession startRunning];
    
    [labelState setText:@"Video capture started"];
    
}

-(void)back{
    //停止摄像头捕抓
    if(self->avCaptureSession){
        [self->avCaptureSession stopRunning];
        self->avCaptureSession= nil;
        [labelState setText:@"Video capture stopped"];
    }
    self->avCaptureDevice= nil;
    //移除localView里面的内容
    for(UIView*view in self->localView.subviews) {
        [view removeFromSuperview];
    }

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)stopVideoCapture
{
    //停止摄像头捕抓
    if(self->avCaptureSession){
        [self->avCaptureSession stopRunning];
        self->avCaptureSession= nil;
        [labelState setText:@"Video capture stopped"];
    }
    self->avCaptureDevice= nil;
    //移除localView里面的内容
    for(UIView*view in self->localView.subviews) {
        [view removeFromSuperview];
    }
}
#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    NSLog(@"获取数据");
    //捕捉数据输出 要怎么处理虽你便
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the buffer*/
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
    {
//        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
//        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
        
        if(self->firstFrame)
        {
            if(1)
            {
                //第一次数据要求：宽高，类型
//                int width = CVPixelBufferGetWidth(pixelBuffer);
//                int height = CVPixelBufferGetHeight(pixelBuffer);
                
                int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
                switch (pixelFormat) {
                    casekCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4
//                        NSLog(@"Capture pixel format=NV12");
                        NSLog(@"1111111111");

                        break;
                    casekCVPixelFormatType_422YpCbCr8:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3
//                        NSLog(@"Capture pixel format=UYUY422");
                        NSLog(@"22222222222");

                        break;
                    default:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;
//                        NSLog(@"Capture pixel format=RGB32");
                        NSLog(@"33333333333");

                        break;
                }
                
                self->firstFrame = NO;
            }
        }
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        if(isStop)
        {
            CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
             CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments];

            [self performSelectorOnMainThread:@selector(updateImage:) withObject:ciImage waitUntilDone:YES];
            
                   }
        
    }
}

-(void)updateImage:(CIImage*)image
{
    UIImage * TPimage = [UIImage imageWithCIImage:image];
    [SaveImage setImage:TPimage];
    isStop = FALSE;
    
    //存储图片
    
    if (TPimage != nil) {
        
        
        //保存到相册
        // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
        
        //拍照片的时间信息
        NSDate *date = [NSDate date];
        NSTimeInterval time = [date timeIntervalSince1970];
        
        
        //取得拍出来的原照片
        CGImageRef imageRef;
        imageRef = [TPimage CGImage];
        NSInteger width;
        NSInteger height;
   
        int orientation = 8;
        width = self.view.frame.size.width;
        height = self.view.frame.size.height;
        
        //画出来一个缩小的图片
        CGSize navSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContext(navSize);
        [TPimage drawInRect:CGRectMake(0, 0, navSize.width, navSize.height)];
        UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIImage *imageForUse = [UIImage imageWithCGImage:scaleImage.CGImage scale:1 orientation:orientation];//缩图
        UIButton *showButton = (UIButton *)[self.view viewWithTag:10];
        //        [showButton setBackgroundImage:imageForUse forState:UIControlStateNormal];//左下角的方形的按钮显示拍下来的图片
        //        showButton.enabled = NO;
        showButton.hidden=YES;
        
        //转换成数据信息存储
        NSData *imageData = UIImageJPEGRepresentation(imageForUse,0.5);
        NSLog(@"data length =[%lu]", (unsigned long)[imageData length]);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *tmpDir =  NSTemporaryDirectory();
        //根据时间所做的路径信息
        NSString *filePath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f", time*1000]];
        if (![fileManager createFileAtPath:filePath contents:imageData attributes:nil]) {
            [self makeAlert:@"保存图片出错"];
        }
        
        //获取快照
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:filePath,@"image",[NSString stringWithFormat:@"%.0f", time*1000], @"time", date, @"date",  [NSString stringWithFormat:@"%d", width], @"width", [NSString stringWithFormat:@"%d", height], @"height",nil];
        [_imageArray addObject:dic];//添加到数组
        
        //最多拍五张
        if ([_imageArray count] == 5) {
            
            UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
            indicator.labelText = @"已拍了5张照片，去处理咯";
            indicator.mode = MBProgressHUDModeText;
            [window addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                sleep(2);
            } completionBlock:^{
                [indicator removeFromSuperview];
                //                [indicator release];
                
                [self showPhoto];
            }];
        }
    }

}

//完成按钮
- (void)showPhoto
{
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //    [self setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
  
    
    if ([_imageArray count] == 0) {
        [self makeAlert:@"还没拍照哦"];
        return;
    }
    //停止摄像头捕抓
    if(self->avCaptureSession){
        [self->avCaptureSession stopRunning];
        self->avCaptureSession= nil;
        [labelState setText:@"Video capture stopped"];
    }
    self->avCaptureDevice= nil;
    //移除localView里面的内容
    for(UIView*view in self->localView.subviews) {
        [view removeFromSuperview];
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        NSLog(@"imageArray is %@",_imageArray);
        NSMutableArray *mutArray = [[NSMutableArray alloc] initWithArray:(NSArray*)[appDelegate.appDefault objectForKey:@"imageEditArray"]];
        [mutArray removeAllObjects];
        [appDelegate.appDefault setObject:mutArray forKey:@"imageEditArray"];
        [_customDelegate cameraPhoto:_imageArray];
    }];
    [[NSNotificationCenter defaultCenter ]postNotificationName:@"imageCollectionReload" object:nil userInfo:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    
    NSLog(@"视图出现的时候的array is %@",[appDelegate.appDefault objectForKey:@"imageEditArray"]);
    
    if ([(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"] count] == 0)
    {
        SaveImage.hidden = YES;
        imageButton.hidden = NO;
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"]];
        _imageArray = array;
    }
    else if([(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"] count] > 0)
    {
        NSLog(@"last object is %@",[(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"] lastObject]);
        
        NSData *data = [NSData dataWithContentsOfFile:[[(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"] lastObject] objectForKey:@"image"] ];
        SaveImage.image = [UIImage imageWithData:data];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:(NSArray *)[appDelegate.appDefault objectForKey:@"imageEditArray"]];
        _imageArray = array;
        
    }
}
-(void)imageClicked
{
    NSLog(@"图片被点击了");
    
    ImageShowController *imageShow = [[ImageShowController alloc] initWithArray:_imageArray];
    
    [self presentViewController:imageShow animated:YES completion:^{
        
    }];
    
}
@end
