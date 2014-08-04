//
//  NewMessageViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-4-22.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "NewMessageViewController.h"
#import "MainAppDelegate.h"
#import "NewMessageCell.h"
#import "WebInfoManager.h"
#import "DeviceConnectManager.h"
@interface NewMessageViewController ()

@end

@implementation NewMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _messageTableView = [[UITableView alloc] init];
    _messageTableView.delegate = self;
    _messageTableView.dataSource = self;
    _messageTableView.allowsSelection = NO;
    _messageTableView.backgroundColor = [UIColor clearColor];
    _label = [[UILabel alloc] init];
    
    [self titleSet:@"分享设备"];
    
}
- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    [_messageTableView reloadData];
    
    NSLog(@"消息数组是%@",[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]]);
//    if ([[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count] == 0)
//    {
//        
//        _messageTableView.frame = CGRectMake(0, 0, 0, 0);
//        
//        _label.frame = CGRectMake(20, 200, 280, 60);
//        _label.textAlignment = NSTextAlignmentCenter;
//        _label.text =@"您还没有设备分享信息";
//        _label.hidden = NO;
//        _label.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:_label];
//    }
//    else
//    {
        _label.hidden = YES;
//    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 300, 40)];
//    topLabel.text = @"您的亲友已经将babywith这款产品分享给你使用，请您选择是否同意使用该产品";
//    topLabel.numberOfLines = 0;
//    topLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    topLabel.font = [UIFont systemFontOfSize:13.0];
//    topLabel.textColor = [UIColor grayColor];
//    topLabel.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:topLabel];
    
        if (130.0*[self tableView:_messageTableView numberOfRowsInSection:0] > self.view.frame.size.height - 66)
        {
            _messageTableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
        }
        else
        {
        _messageTableView.frame = CGRectMake(0, 0, 320, 130.0*[self tableView:_messageTableView numberOfRowsInSection:0]);

        }
   // }
    [self.view addSubview:_messageTableView];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

   //return  [[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count];
    
    return 6;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = @"NewMessageIdentifier";
    
    NewMessageCell *cell = (NewMessageCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NewMessageCell1" owner:self options:nil];
       cell = [nib objectAtIndex:0];
    }
    
    
   // cell.messageLabel.text = [NSString stringWithFormat:@"%@ ",[appDelegate.appDefault objectForKey:@"alert"]];
    
   cell.messageLabel.text = @"您好，张三将它使用的设备 工地监控一 分享给你，是否同意该监控？";
    
    [cell.agreeShareBtn addTarget:self action:@selector(agreeShare:) forControlEvents:UIControlEventTouchUpInside];
    [cell.refuseShareBtn addTarget:self action:@selector(refuseShare:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 90.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;

}


#pragma mark shareFunction

-(void)agreeShare:(UIButton *)btn
{
    NSLog(@"同意分享1");
    UITableViewCell *cell = (UITableViewCell *)[btn superview];
    NSIndexPath *indexPath = [self.messageTableView indexPathForCell:cell];
    
    NSString *IDMer = [NSString stringWithFormat:@"%@",[[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] objectAtIndex:indexPath.row]];
    
    
    NSLog(@"iiiiiiiiiiiiii%@",IDMer);
    if ([appDelegate.webInfoManger UserAgreeAddDeviceUsingIDMer:IDMer Toekn:[appDelegate.appDefault objectForKey:@"Token"]])
    {
        NSLog(@"分享成功");
        
        NSLog(@"messageArray is %@",appDelegate.messageArray);
        
        [appDelegate.messageArray addObjectsFromArray: [appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]]];
        [appDelegate.messageArray removeObjectAtIndex:indexPath.row];
        [appDelegate.appDefault setObject:appDelegate.messageArray forKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]];
        [appDelegate.messageArray removeAllObjects];
        [self.messageTableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
     else
    {
    
        [self makeAlert:@"同意分享出错"];
  
    }

}
 -(void)refuseShare:(UIButton *)btn
    
{

    NSLog(@"拒绝别人的分享");
    UITableViewCell *cell = (UITableViewCell *)[btn superview];
    NSIndexPath *indexPath = [self.messageTableView indexPathForCell:cell];
    [appDelegate.messageArray addObjectsFromArray: [appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]]];
    [appDelegate.messageArray removeObjectAtIndex:indexPath.row];
    [appDelegate.appDefault setObject:appDelegate.messageArray forKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]];
    [appDelegate.messageArray removeAllObjects];
    [self.messageTableView reloadData];
    
    
    if ([[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@$",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count]==0)
    {
        [_messageTableView removeFromSuperview];
        _label.frame = CGRectMake(20, 200, 280, 60);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text =@"您还没有设备分享信息";
        _label.hidden = NO;
        _label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_label];
    }


}

@end
