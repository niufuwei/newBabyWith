//
//  ImageShowController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-6-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ImageShowController.h"
#import "MainAppDelegate.h"
@interface ImageShowController ()
{

    UIView *topView;

}
@end

@implementation ImageShowController

- (id)initWithArray:(NSArray *)array{
    self = [super init];
    if (self) {
        // Custom initialization
        _photoArray = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}



-(void)viewDidLoad{
    
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor blackColor];
    
    //导航条设置
    
        topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        
        UIImageView *aImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 64)];
        aImage.image = [UIImage imageNamed:@"导航栏背景.png"];
        [topView addSubview:aImage];
        
//        topView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:topView];
        
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 22+10, 10, 20)];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"返回.png"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToCamera) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:backBtn];
        
        //右导航--删除按钮
        UIButton *setButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 17+10, 60, 30)];
        
        [setButton addTarget:self action:@selector(deletePic) forControlEvents:UIControlEventTouchUpInside];
        [setButton setTitle:@"删除" forState:UIControlStateNormal];
        setButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
        setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        setButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [topView addSubview:setButton];
        
        
        
        pageCount = [_photoArray count];
        NSLog(@"%@",_photoArray);
        _currentPage = [_photoArray count] -1;
        _image = [[UIImage alloc]init];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 10+10, 110, 44)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [NSString stringWithFormat:@"%d/%d", _currentPage+1, pageCount];
        titleLabel.textColor = babywith_text_background_color;
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.tag = 101;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [topView addSubview:titleLabel];
        

    
    float contentHeight = self.view.frame.size.height;
    NSLog(@"self.view height %f",contentHeight);
    _photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, 320, contentHeight - 64)];
    _photoScrollView.pagingEnabled = YES;
    _photoScrollView.delegate = self;
    _photoScrollView.contentSize = CGSizeMake(320*pageCount,contentHeight - 64);
    _photoScrollView.showsHorizontalScrollIndicator = NO;
    _photoScrollView.showsVerticalScrollIndicator = NO;
    _photoScrollView.scrollEnabled = YES;
    
    
    int i=0;
    for (NSDictionary *dic in _photoArray)
    {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i*320, 0, 320, _photoScrollView.frame.size.height)] ;
        view.tag = i+1;
        
        
        NSData *imageData = [NSData dataWithContentsOfFile:[dic objectForKey:@"image"]];
       // NSLog(@"%@",imageData);
        UIImage *image = [UIImage imageWithData:imageData];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image] ;
        
        
        imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            
        
        [view addSubview:imageView];
        [_photoScrollView addSubview:view];
        
        i++;
    }
    
    [self.view addSubview:_photoScrollView];
    
    NSLog(@"current page is %d",_currentPage);
    CGRect temp = _photoScrollView.frame;
    CGPoint tem =_photoScrollView.contentOffset;
    tem.x = temp.size.width*_currentPage;
    [_photoScrollView setContentOffset:tem];
    
}
-(void)backToCamera
{

    NSLog(@"退出的时候的数组是%@",_photoArray);
    [appDelegate.appDefault setObject:_photoArray forKey:@"imageEditArray"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];


}

#pragma mark -scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    _currentPage = (_scrollView.contentOffset.x /_scrollView.frame.size.width);
    ((UILabel *)[topView viewWithTag:101]).text = [NSString stringWithFormat:@"%d/%d", _currentPage+1, pageCount];
    
}




-(void)deletePic
{
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"是否确定删除" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alert.tag=10010;
    [alert show];
    
}
#pragma mark -UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        int index = _currentPage;
        
        [[_photoScrollView viewWithTag:index+1] removeFromSuperview];
        
        for (int i= index+2; i<pageCount+1; i++)
        {
            UIView *view = [_photoScrollView viewWithTag:i];
            view.tag = i-1;
            view.frame = CGRectMake((i-2)*320, 0, 320, 480);
        }
        
        pageCount -= 1;
        
        if (pageCount == 0)
        {
            [_photoArray removeAllObjects];
            NSLog(@"photoArray is %@",_photoArray);
            [appDelegate.appDefault setObject:_photoArray forKey:@"imageEditArray"];
            NSLog(@"返回的时候的照片数组是%@",[appDelegate.appDefault objectForKey:@"imageEditArray"]);
            [self dismissViewControllerAnimated:YES completion:^{
                
                
                NSLog(@"dismiss complete");
                
            }];
            return;
        }
        else
        {
            _photoScrollView.contentSize = CGSizeMake(320*(pageCount),self.view.frame.size.height-44-60-30);
            _currentPage =  (_photoScrollView.contentOffset.x /_photoScrollView.frame.size.width);
            NSLog(@"当前的currentPage是%d",_currentPage);
            
            
            
            ((UILabel *)[topView viewWithTag:101]).text = [NSString stringWithFormat:@"%d/%d", _currentPage+1, pageCount];
            
            [_photoArray removeObjectAtIndex:index];
            NSLog(@"数组%@",_photoArray);
        }
        
        

       
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



@end
