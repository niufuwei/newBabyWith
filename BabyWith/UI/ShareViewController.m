//
//  ShareViewController.m
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "ShareViewController.h"
#import "MainAppDelegate.h"
#import "DeviceConnectManager.h"
#import "SetNickNameViewController.h"
#import "ShareDeviceViewController.h"
#import "WebInfoManager.h"
#import "ShareCell.h"
@interface ShareViewController ()

@end

@implementation ShareViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self titleSet:@"分享"];
    
    // Do any additional setup after loading the view from its nib.
    
    _shareListTable = [[UITableView alloc] init];
    _label = [[UILabel alloc] init];
    _nextStepBtn = [[UIButton alloc] init];
    
    
    _shareListTable.delegate = self;
    _shareListTable.dataSource = self;
    _shareListTable.scrollEnabled = NO;
    _shareListTable.backgroundColor = [UIColor clearColor];
    _shareListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    
}


-(void)nextStep
{

    int i =  [appDelegate.deviceConnectManager getDeviceCount];
    NSLog(@"设备一共有%d个",i);
    for (int j = 0; j< i; j++)
    {
        
        NSLog(@"indexPath  %@",[NSIndexPath indexPathForRow:j inSection:0]);
        
        
        ShareCell *shareCell = (ShareCell *)[_shareListTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:0]];
        if (shareCell.chooseImage.image == [UIImage imageNamed:@"选择 (2).png"] )
        {
            
            
            _hasSelect = YES;
            [appDelegate.selectDeviceArr addObject:[appDelegate.deviceConnectManager getDeviceInfoAtRow:j]];
            
            NSLog(@"qqqqqqq%@",[appDelegate.deviceConnectManager getDeviceInfoAtRow:j]);

        }
        
    }
    
    
    NSLog(@"选中的设备的数量是%d",[appDelegate.selectDeviceArr count]);
    
    
    //有选中的话根据数据库有没有昵称进入不同的页面
    if (_hasSelect == YES)
    {
            _hasSelect = NO;
            ShareDeviceViewController *vc = [[ShareDeviceViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

    }
    else
    {
        //否则提示至少选择一台设备
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"至少选择一台设备";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
        }];
        
    
    }
    
    

}
- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    
    [_shareListTable reloadData];
    
    if ([self tableView:_shareListTable numberOfRowsInSection:0] == 0)
    {
        
        _shareListTable.frame = CGRectMake(0, 0, 0, 0);
        
        _label.frame = CGRectMake(20, 200, 280, 60);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text =@"您还没有绑定设备";
        _label.hidden = NO;
        _label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_label];
        
    }
    else
    {
        _label.hidden = YES;
        
        _shareListTable.frame = CGRectMake(0,0, 320, [self tableView:_shareListTable numberOfRowsInSection:0]* 80 + 100);
        _shareListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSLog(@"tableview的高度是%f",_shareListTable.frame.size.height);
                
        
        
    }
    [self.view addSubview:_shareListTable];

    
    //NSLog(@"拥有的设备数量是%d",[appDelegate.deviceConnectManager getDeviceCount]);

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [appDelegate.deviceConnectManager getDeviceCount];
    NSLog(@"拥有的设备数量是%d",[appDelegate.deviceConnectManager getDeviceCount]);

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = @"ShareListIdentifier";
    ShareCell * cell = (ShareCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    cell.backgroundColor = [UIColor whiteColor];
    NSInteger row = [indexPath row];
    cell.nameLabel.text = [[appDelegate.deviceConnectManager getDeviceInfoAtRow:row] objectForKey:@"name"];
    
    
    if ([appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@_time",[[appDelegate.deviceConnectManager getDeviceInfoAtRow:row] objectForKey:@"device_id"]]])
    {
        
        cell.bindTimeLabel.text =[NSString stringWithFormat:@"绑定时间：%@",[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@_time",[[appDelegate.deviceConnectManager getDeviceInfoAtRow:row] objectForKey:@"device_id"]]]];
    }
    
//    cell.imageCell.image = [UIImage imageNamed:@"设备.png"];
    cell.chooseImage.image = [UIImage imageNamed:@"选择 (1).png"];
    return cell;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{

    return @"hello world";


}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    return 100;




}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _nextStepBtn.frame = CGRectMake(35, 30, 250, 35);
    [self configurationForGreenButton:_nextStepBtn];
    [_nextStepBtn setBackgroundImage:[UIImage imageNamed:@"qietu_118.png"] forState:UIControlStateNormal];
    [_nextStepBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    _nextStepBtn.hidden = NO;
    [footerView addSubview:_nextStepBtn];
    
    return footerView;


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ShareCell * cell = (ShareCell *)[_shareListTable cellForRowAtIndexPath:indexPath];
    
    if (cell.chooseImage.image == [UIImage imageNamed:@"选择 (1).png"])
    {
        cell.chooseImage.image = [UIImage imageNamed:@"选择 (2).png"];
        
        
        

        
    }
    else
    {
        cell.chooseImage.image = [UIImage imageNamed:@"选择 (1).png"];
        

    
    }
   

    
}


- (void)viewDidUnload {
    [self setShareListTable:nil];
    [super viewDidUnload];
}
@end
