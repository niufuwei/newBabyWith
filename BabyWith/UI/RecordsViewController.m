//
//  RecordsViewController.m
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "RecordsViewController.h"
#import "ImagePickerController.h"
#import "MainAppDelegate.h"
#import "SQLiteManager.h"
#import "CollectionCell.h"
#import "HeaderView.h"
#import "PhotoScanViewController.h"
#import "AppGlobal.h"
#import "myCollectionViewCell.h"
#import "AVCallController.h"

//#define REUSEABLE_CELL_IDENTITY @"CELL"
#define REUSEABLE_HEADER @"HEADER"
@interface RecordsViewController ()
{
    UIButton *leftButton;
    UIButton * rightButton;
}
@end

int flag_monthList = 0;
int pre_month=12;
int ppre_month=13;
static NSString * REUSEABLE_CELL_IDENTITY = @"cee";
@implementation RecordsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    isDelete = FALSE;
    // Do any additional setup after loading the view from its nib.
    
//    isFirst=TRUE;
    
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollentView) name:@"imageCollectionReload" object:nil];
    
    leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    [navButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
//    [navButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateHighlighted];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];
//    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [leftButton setBackgroundColor:[UIColor whiteColor]];
    [leftButton addTarget:self action:@selector(Edit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *LeftItem = [[UIBarButtonItem alloc] initWithCustomView: leftButton];
    self.navigationItem.leftBarButtonItem = LeftItem;
    
    rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //    [navButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
    //    [navButton setImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateHighlighted];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
    //    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [leftButton setBackgroundColor:[UIColor whiteColor]];
    [rightButton addTarget:self action:@selector(RightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView: rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;

    
    
    [rightButton setBackgroundImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
    self.delegate = self;
    
    [self titleSet:@"记录"];
    arrayDictionary = [[NSMutableDictionary alloc] init];
    statusDictionary = [[NSMutableDictionary alloc] init];
    RowDictionary = [[NSMutableDictionary alloc] init];
    deleteArray = [[NSMutableArray alloc] init];
    
    _label = [[UILabel alloc] init];
    
    _year = 0;
    localLoadFlag = 0;
    _recordLocalMonthListDic = [[ NSMutableDictionary alloc] initWithCapacity:1];
    _recordLocalMonthCountDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    _deleteDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    _yearArray = [[NSMutableArray alloc] init];
    _countForSectionArray = [[NSMutableArray alloc] init];
    _sectionArray = [[NSMutableArray alloc] init];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy.MM.dd"];
    //
    
//    [appDelegate.sqliteManager getLocalListOfYearCount];
//    _yearArray = appDelegate.recordLocalYearCountArray;
    
    UICollectionViewFlowLayout *fl =[[UICollectionViewFlowLayout alloc] init];
    _imageCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, kScreenHeight - 64 - 44) collectionViewLayout:fl];
    _imageCollection.backgroundColor = [UIColor clearColor];
    _imageCollection.delegate = self;
    _imageCollection.dataSource = self;
    //    [_imageCollection registerClass:[CollectionCell class] forCellWithReuseIdentifier:REUSEABLE_CELL_IDENTITY];
    //
    [_imageCollection registerClass:[HeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:REUSEABLE_HEADER];
    
//    [fl release];
    [self.view addSubview:_imageCollection];
    
//    NSLog(@"viewwillAppear调用");
    [self performSelector:@selector(ShowRecordList) withObject:nil afterDelay:0.1];
}

-(void)Edit:(id)sender
{
    if(!isDelete)
    {
        isDelete = TRUE;
        //换一张图片
//        [leftButton setTitle:@"取消" forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"编辑2.png"] forState:UIControlStateNormal];

        [rightButton setBackgroundImage:[UIImage imageNamed:@"删除.png"] forState:UIControlStateNormal];
        [_imageCollection reloadData];
    }
    else
    {
        isDelete = FALSE;
//        [leftButton setTitle:@"编辑" forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];
        [deleteArray removeAllObjects];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];

        [_imageCollection reloadData];

    }
    
}

-(void)RightButtonClick
{
    if(!isDelete)
    {
        _picker = [[ImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            _picker.customDelegate = self;
            [self presentViewController:_picker animated:YES completion:^{
                
            }];
        }
        
//        AVCallController * avcall = [[AVCallController alloc] init];
//        [self presentViewController:avcall animated:YES completion:^{
//            
//        }];

    }
    else
    {
        
        NSLog(@"%@",deleteArray);
        for(int i = 0 ;i<deleteArray.count;i++)
        {
            //删除选中图片
            NSDictionary * dic = [deleteArray objectAtIndex:i];
           
            [appDelegate.sqliteManager removeRecordInfo:[[[deleteArray objectAtIndex:i] allKeys] objectAtIndex:0] deleteType:1];
     
            //看是否是有视频，有视频就删除视频
            if ([[[dic objectForKey:[[[deleteArray objectAtIndex:i] allKeys] objectAtIndex:0]] objectForKey:@"is_vedio"] intValue]==1)
            {
                //删除视频
                NSString *vedioPath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address
                                                                        stringByAppendingPathComponent:[[dic objectForKey:[[[deleteArray objectAtIndex:i] allKeys] objectAtIndex:0]] objectForKey:@"record_data_path"]]];
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:vedioPath error:&error];
                if (!error)
                {
                    NSLog(@"删除视频成功");
                }
            }
           
        }
        [_sectionArray removeAllObjects];
        [RowDictionary removeAllObjects];
        [arrayDictionary removeAllObjects];
        [_countForSectionArray removeAllObjects];
        [self ShowRecordList];

        isDelete = FALSE;
        [leftButton setBackgroundImage:[UIImage imageNamed:@"编辑.png"] forState:UIControlStateNormal];

//        [leftButton setTitle:@"编辑" forState:UIControlStateNormal];
        [deleteArray removeAllObjects];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"拍照.png"] forState:UIControlStateNormal];
        
        [_imageCollection reloadData];

    }
}

-(void)viewWillAppear:(BOOL)animated
{
     if (isFirst)
    {
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isSaveVideo"] isEqualToString:@"1"])
        {
            
            
            [self reloadCollentView];
        }
    }
    isFirst=TRUE;
}

-(void)reloadCollentView
{
    
    [RowDictionary removeAllObjects];
    [arrayDictionary removeAllObjects];
    [statusDictionary removeAllObjects];
    
    
    [_countForSectionArray removeAllObjects];
    [_sectionArray removeAllObjects];
    
   
    
//    UICollectionViewFlowLayout *fl =[[UICollectionViewFlowLayout alloc] init];
//    _imageCollection = [[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, kScreenHeight - 64 - 44) collectionViewLayout:fl] autorelease];
//    _imageCollection.backgroundColor = [UIColor clearColor];
//    _imageCollection.delegate = self;
//    _imageCollection.dataSource = self;
//    //    [_imageCollection registerClass:[CollectionCell class] forCellWithReuseIdentifier:REUSEABLE_CELL_IDENTITY];
//    //
//    [_imageCollection registerClass:[HeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:REUSEABLE_HEADER];
//    
//    [fl release];
//    [self.view addSubview:_imageCollection];
    
//    NSLog(@"viewwillAppear调用");
    [self performSelector:@selector(ShowRecordList) withObject:nil afterDelay:0.1];

}


-(void)viewDidDisappear:(BOOL)animated
{
  
    
//    NSLog(@"viewwilldisappear调用");

}
-(int)getEveryMonthRecordSum
{

    int j = 0;
    for (int i = 1; i <=12; i++)
    {
      j += [[[appDelegate.recordLocalMonthCountDic objectForKey:[[_yearArray objectAtIndex:[_yearArray count]-1] objectForKey:@"Year"]] objectForKey:[NSString stringWithFormat:@"%d",i]] intValue];

    }
    return j;

}
-(void)ShowRecordList
{
    [appDelegate.sqliteManager getLocalListOfYearCount];
    _yearArray = appDelegate.recordLocalYearCountArray;

    
    if ([_yearArray count] > 0)
    {
        [appDelegate.sqliteManager getLocalListOfMonthCountFromYear:[[[_yearArray objectAtIndex:[_yearArray count]-1] objectForKey:@"Year"] integerValue]];

        if ([self getEveryMonthRecordSum] > 0)
        {
            _label.hidden = YES;
            //加载的是本地的记录信息
            //这里取得的是最后一个数据，也就是最新的数据，因为我们每一次调用viewAppear的时候都会给appDelegate.recordLocalYearCountArray一个新值，所以这里取得的应该是本年度的最新的记录数
            [self LoadLocalRecord:[[[_yearArray objectAtIndex:[_yearArray count]-1] objectForKey:@"Year"] integerValue]];
       }
        else
        {
            _label.frame = CGRectMake(20, 200, 280, 60);
            _label.textAlignment = NSTextAlignmentCenter;
            _label.text =@"您还没有记录信息";
            _label.hidden = NO;
            _label.backgroundColor = [UIColor clearColor];
            [self.view addSubview:_label];
            [_imageCollection reloadData];
        
        }
        
        
    }
    else
    {
        _label.frame = CGRectMake(20, 200, 280, 60);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text =@"您还没有记录信息";
        _label.hidden = NO;
        _label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_label];
    
    }


}
//取得本地的记录并更新数据
-(void)LoadLocalRecord:(int)year{
    
    
    _year = year;
    //第一次处理该年份 获取该年份内每个月的记录条数 获取该年份总记录列表 设置各个月份记录列表
    [appDelegate.sqliteManager getLocalListOfYearCount];

    [appDelegate.sqliteManager getLocalListOfMonthCountFromYear:_year];
    
    _recordLocalMonthCountDic = [appDelegate.recordLocalMonthCountDic objectForKey:[NSString stringWithFormat:@"%d", _year]];
    
    [appDelegate.sqliteManager getLocalRecordInfoListFromYear:_year iphone:[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]];
    
    
    
    
    
    [self setMonthListOfYear:_year];
    
    
    for (int i = 12; i>0; i--)
    {
        [appDelegate.sqliteManager getLocalListofDayCountFromMonth:i Year:_year];
        
        [self setDaysListFromMonth:i Year:_year];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"isSaveVideo"];
    
    
    
    
    [_imageCollection reloadData];
    

    
}
#pragma mark MonthList  Set
/*设置每个月的记录的字典*/
//只是这里为什么是在数据库取得的数据，又存回到数据库  ？？？？？？？？？？？？？
-(void)setMonthListOfYear:(int)year
{
    if ([appDelegate.recordLocalMonthCountDic objectForKey:[NSString stringWithFormat:@"%d", year]] == nil) {
        return;
    }
    
    //取得本地的某一年的月记录
    //也就是一年所有的记录
    NSArray *localArray = [NSArray arrayWithArray:[appDelegate.recordLocalYearMonthListDic objectForKey:[NSString stringWithFormat:@"%d", year]]];
    if ([localArray count] ==0) {
        return;
    }
    
    
    int count = 0;
    for (NSInteger i= 12; i>0; i--)
    {
        
        //每个月的记录数量
        NSInteger num = [[_recordLocalMonthCountDic objectForKey:[NSString stringWithFormat:@"%d", i]] integerValue];
        if (num == 0 ) {
            continue;
        }
        
        
        //这个recordArray每次进来之后都是重新定义的
        //我们取数据是在localArray里面取得，数组里面的排列是先后顺序，先取最新的，比如从0开始的20个，那么下次的话就是从21开始的比如15个，下下次就是36开始的比如10个
        NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[localArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(count, num)]]];
        
        
        //存入到本地属性
        [_recordLocalMonthListDic setObject:recordArray forKey:[NSString stringWithFormat:@"%d",i]];
        count += num;
    }
    //全部记录，取得每个月的之后存入到这个年份里面
    [appDelegate.recordLocalYearMonthListDic setObject:_recordLocalMonthListDic forKey:[NSString stringWithFormat:@"%d", year]];

    
}
-(int)getDaysFromMonth:(int)month Year:(int)year
{
    int i = 0;
    switch (month) {
        case 12:
            i= 31;
            break;
        case 11:
            i= 30;
            break;
        case 10:
            i= 31;
            break;
        case 9:
            i= 30;
            break;
        case 8:
            i= 31;
            break;
        case 7:
            i= 31;
            break;
        case 6:
            i= 30;
            break;
        case 5:
            i= 31;
            break;
        case 4:
            i= 30;
            break;
        case 3:
            i= 31;
            break;
        case 2:
        {
            if ((year % 400 == 0)||((year % 4 == 0)&&(year % 100 !=0))) {
                i= 29;
            }
            else
            {
            
                i= 28;
            
            }
 
        }
            break;
        case 1:
            i= 31;
            break;
        default:
            break;
    }

    return i;


}
-(void)setDaysListFromMonth:(int)month Year:(int)year
{

    //某一个月的记录数
    NSArray *localArray = [_recordLocalMonthListDic objectForKey:[NSString stringWithFormat:@"%d",month]];
    if ([localArray count] ==0)
    {
        return;
    }
    int days = [self getDaysFromMonth:month Year:_year];
    int count = 0;
    for (NSInteger i =days; i>0; i--) {
        NSInteger num = [[[appDelegate.recordLocalDayCountDic objectForKey:[NSString stringWithFormat:@"%d",month]] objectForKey:[NSString stringWithFormat:@"%d",i]]integerValue];
        if (num ==0) {
            continue;
        }
        NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[localArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(count, num)]]];
        if (num !=0) {
            
            [_countForSectionArray addObject:[NSString stringWithFormat:@"%d",num]];
            [_sectionArray addObject:recordArray];
            
        }
        count += num;
    }

//    NSLog(@"数组是%@,section总数是%@",_countForSectionArray,_sectionArray);
}

//进入拍照页面
//-(void)takePic:(UIBarButtonItem *)item
//{
//
//    _picker = [[ImagePickerController alloc] init];
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        [_picker setSourceType:UIImagePickerControllerSourceTypeCamera];
//        _picker.customDelegate = self;
//        [self presentViewController:_picker animated:YES completion:^{
//            
//        }];
//    }
//
//}

//这里要将新增加的照片数据显示出来
//那么就要添加到数据库，从数据库取出来，显示到界面上
-(void)cameraPhoto:(NSArray *)imageArra
{
    

    for (NSDictionary *dic in imageArra)
    {
        NSData *imageData = [NSData dataWithContentsOfFile:[dic objectForKey:@"image"]];
        
        //记录的日期
        NSDate *saveDate = [dic objectForKey:@"date"];
        unsigned units  = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
        NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
        NSDateComponents *nowComp = [myCal components:units fromDate:saveDate];
        
        
        //记录ID
        NSString *record_id = [NSString stringWithFormat:@"%@_%@",[dic objectForKey:@"time" ],[appDelegate.appDefault objectForKey:@"Member_id_self"]];
        

        //图片相对路径
        NSString *path = [NSString stringWithFormat:@"/image/record/%d/%d/%d/%d/%@.png",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id];
        
        //创建一个自动释放池
        //保存图片到沙盒目录
        NSString *imagePath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path]];
        NSString *imageDir = [NSString stringWithFormat:@"%@",[imagePath stringByDeletingLastPathComponent]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:&error];
        
        //视频流相对路径
        //这里加入了视频流的路径，让所有的图片保存保持一样的参数，但是在这里并没有存入视频，取的时候也不会用到这个视频的路径
        NSString *path1 = [NSString stringWithFormat:@"/vedio/record/%d/%d/%d/%d/%@.pm4",[nowComp year],[nowComp month],[nowComp day],[[appDelegate.appDefault objectForKey:@"Member_id_self"] integerValue]%10,record_id];
        NSString *vedioPath = [NSString stringWithFormat:@"%@",[babywith_sandbox_address stringByAppendingPathComponent:path1]];
        NSString *vedioDir = [NSString stringWithFormat:@"%@",[vedioPath stringByDeletingLastPathComponent]];
        NSError *vedioError = nil;
        [fileManager createDirectoryAtPath:vedioDir withIntermediateDirectories:YES attributes:nil error:&vedioError];
        
        
        if (!error)
        {
            if ([fileManager createFileAtPath:imagePath contents:imageData attributes:nil])
            {
                //插入表库
                NSArray *array = [NSArray arrayWithObjects:record_id,[appDelegate.appDefault objectForKey:@"Member_id_self"],[dic objectForKey:@"time"],[NSString stringWithFormat:@"%d",[nowComp year]],[NSString stringWithFormat:@"%d",[nowComp month]],[NSString stringWithFormat:@"%d",[nowComp day]],[dic objectForKey:@"width"],[dic objectForKey:@"height"],path,[NSString stringWithFormat:@"%d",0],path1,nil];
                
                NSArray *keyArray = [NSArray arrayWithObjects:@"id_record", @"id_member", @"time_record",@"year_record",@"month_record",@"day_record",@"width_image",@"height_image",@"path",@"is_vedio",@"record_data_path", nil];
                NSDictionary *insertDic = [NSDictionary dictionaryWithObjects:array forKeys:keyArray];
                
                //插入到数据库
                [appDelegate.sqliteManager insertRecordInfo:insertDic];
                [self.imageCollection reloadData];
            }
            
        }
        else
        {
            [self makeAlert:@"保存图片错误!"];
        }
    }
    
   

}

#pragma mark -CollectionDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_countForSectionArray objectAtIndex:section] integerValue];
    
    
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_imageCollection registerClass:[myCollectionViewCell class] forCellWithReuseIdentifier:REUSEABLE_CELL_IDENTITY];
    myCollectionViewCell *cell = [_imageCollection dequeueReusableCellWithReuseIdentifier:REUSEABLE_CELL_IDENTITY forIndexPath:indexPath];
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:[[_sectionArray  objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];

    
    if(![[RowDictionary objectForKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]] isEqualToString:@"ok"])
    {
       
        NSData *imageData = [NSData dataWithContentsOfFile: [babywith_sandbox_address stringByAppendingPathComponent:[dic objectForKey:@"path"]]];
        
        UIImage *image = [UIImage imageWithData:imageData];
        
        [arrayDictionary setObject:image forKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]];

        
        [cell.image setImage:image];
        //假如是视频图片，要加一个按钮一样的图片加以区别
        if ([[dic objectForKey:@"is_vedio"] intValue] !=1)
        {
            [cell.videoImage setHidden:YES];
            [statusDictionary setObject:@"0" forKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]];
            
        }
        else
        {
            [statusDictionary setObject:@"1" forKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]];
            [cell.videoImage setHidden:NO];
        }
        
        [RowDictionary setObject:@"ok" forKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]];

    }
    else{
        
        [cell.image setImage:[arrayDictionary objectForKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]]];

        
        if(![[statusDictionary objectForKey:[NSString stringWithFormat:@"%d",(indexPath.section+1)*1000+indexPath.row]] isEqualToString:@"1"])
        {
            [cell.videoImage setHidden:YES];
        }
        else
        {
            [cell.videoImage setHidden:NO];
            
        }
    }
    
    [cell.deleteImage setHidden:YES];
    if(isDelete)
    {
        [cell.deleteImage setHidden:NO];
        BOOL isExit = FALSE;
        if(deleteArray.count ==0)
        {
//            [cell.deleteImage setImage:[UIImage imageNamed:@"选择 (1).png"]];
            [cell.deleteImage setHidden: YES];
        }
        else
        {
            for(int i=0;i<deleteArray.count;i++)
            {
                if([[deleteArray objectAtIndex:i] objectForKey:[[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_record"]])
                {
                    NSLog(@"存在");
                    isExit = TRUE;
                    [cell.deleteImage setImage:[UIImage imageNamed:@"qietu_34.png"]];
                    break;
                }
                else
                {
                    isExit = FALSE;
                    //不存在
                }
            }
            if(!isExit)
            {
//                [cell.deleteImage setImage:[UIImage imageNamed:@"选择 (1).png"]];
                [cell.deleteImage setHidden:YES];

            }

        }
    }
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeaderView *headerView = [_imageCollection dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:REUSEABLE_HEADER forIndexPath:indexPath];
    
     NSDictionary *dic = [NSDictionary dictionaryWithDictionary:[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    
    headerView.headerLabel.text = [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"time_record"] doubleValue]/1000]];
    headerView.headerLabel.textColor = [UIColor grayColor];
    
    if(selectButton)
    {
        [selectButton removeFromSuperview];
    }
    selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    selectButton.frame = CGRectMake(self.view.frame.size.width-55, 10, 45,20 );
    selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectButton setBackgroundImage:[UIImage imageNamed:@"qietu_15.png"] forState:UIControlStateNormal];
    selectButton.tag = indexPath.section+1;
    [selectButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    if(!isDelete)
    {
        selectButton.hidden = YES;

    }
    else
    {
        selectButton.hidden = NO;

    }
    [headerView addSubview:selectButton];
    return headerView;


}

-(void)onDelete:(id)sender
{
    isAllSelect = !isAllSelect;
    
    UIButton * btn = (UIButton*)sender;
    NSMutableArray *currentSectionPhoto = [_sectionArray objectAtIndex:btn.tag -1];
    
    NSLog(@"%@",currentSectionPhoto);
    NSLog(@"%d",btn.tag);
    NSLog(@"%@",deleteArray);
    
    if(isAllSelect)
    {
        [selectButton setBackgroundImage:[UIImage imageNamed:@"qietu_15.png"] forState:UIControlStateNormal];

        BOOL isExit = FALSE;
        for(int i = 0;i<currentSectionPhoto.count;i++)
        {
            NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:btn.tag-1];
            myCollectionViewCell * cell = (myCollectionViewCell *)[_imageCollection cellForItemAtIndexPath:indexpath];
            
            for(int j = 0;j<deleteArray.count;j++)
            {
//                NSLog(@"%@",currentSectionPhoto);
//                NSLog(@"%@",deleteArray);
                if([[deleteArray objectAtIndex:j] objectForKey:[[currentSectionPhoto objectAtIndex:i] objectForKey:@"id_record"]])
                {
                    isExit = TRUE;
                    break;
                }
                else
                {
                    isExit = FALSE;
                }

            }
           
            if(!isExit)
            {
                //如果数据不存在，就插入

                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                [dic setObject:[currentSectionPhoto objectAtIndex:i] forKey:[[currentSectionPhoto objectAtIndex:i] objectForKey:@"id_record"]];
                
                [cell.deleteImage setHidden:NO];
                [cell.deleteImage setImage:[UIImage imageNamed:@"qietu_34.png"]];
                [deleteArray addObject:dic];

            }
            else
            {
                //如果数据存在，就不操作
                
            }
        }

    }
    else
    {
        [selectButton setBackgroundImage:[UIImage imageNamed:@"编辑记录.png"] forState:UIControlStateNormal];

         for(int i = 0;i<currentSectionPhoto.count;i++)
         {
             NSIndexPath * indexpath = [NSIndexPath indexPathForRow:i inSection:btn.tag-1];
             myCollectionViewCell * cell = (myCollectionViewCell *)[_imageCollection cellForItemAtIndexPath:indexpath];
             
             for(int j = 0;j<deleteArray.count;j++)
             {
                 if([[deleteArray objectAtIndex:j] objectForKey:[[currentSectionPhoto objectAtIndex:i] objectForKey:@"id_record"]])
                 {
                     [cell.deleteImage setHidden:YES];
                     [deleteArray removeObjectAtIndex:j];
                     break;
                 }
             }
             
         }
        
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75.5, 75.5);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(5, 0, 5, 0);
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return [_sectionArray count];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([[_sectionArray objectAtIndex:section] count] == 0) {
        return CGSizeZero;
    }
    else
    {
    return CGSizeMake(320, 30);

    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    return YES;

}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    myCollectionViewCell * cell = (myCollectionViewCell*)[_imageCollection cellForItemAtIndexPath:indexPath];
    
    if(isDelete)
    {
        [cell.deleteImage setHidden:NO];
        BOOL isExit = FALSE;
        if([deleteArray count] ==0)
        {
            NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]forKey:[[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_record"]];
            
            NSLog(@"已插入");
            [cell.deleteImage setImage:[UIImage imageNamed:@"qietu_34.png"]];
            

            [deleteArray addObject:dic];
        }
        else
        {
            for(int i=0;i<deleteArray.count;i++)
            {
                if([[deleteArray objectAtIndex:i] objectForKey:[[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_record"]])
                {
                    NSLog(@"存在");
//                    [cell.deleteImage setImage:[UIImage imageNamed:@"选择 (1).png"]];
                    [cell.deleteImage setHidden:YES];
                    [deleteArray removeObjectAtIndex:i];
                    isExit = TRUE;
                    break;

                }
                else
                {
                    isExit = FALSE;
                }
            }
            if(!isExit)
            {
                NSMutableDictionary * temp_dic = [[NSMutableDictionary alloc] init];
                [temp_dic setObject:[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]forKey:[[[_sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"id_record"]];
                
                [cell.deleteImage setImage:[UIImage imageNamed:@"qietu_34.png"]];
                
                [deleteArray addObject:temp_dic];
            }

        }
        
    }
    else
    {
        NSMutableArray *currentSectionPhoto = [_sectionArray objectAtIndex:indexPath.section];
        
        PhotoScanViewController *photoController = [[PhotoScanViewController alloc] initWithArray:currentSectionPhoto Type:0 CurrentPage:indexPath.row Delegate:nil];
        [self.navigationController pushViewController:photoController animated:YES];

    }
    
    NSLog(@"%@",deleteArray);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{

    return 6.0;


}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{

    return 6.0;


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}
@end
