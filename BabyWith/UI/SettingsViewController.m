//
//  SettingsViewController.m
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "SettingsViewController.h"
#import "MainAppDelegate.h"
#import "ListCell.h"
#import "WebInfoManager.h"


#import "ChaneNickNameViewController.h"
#import "ChangePasswordViewController.h"
#import "MessagViewController.h"
#import "AboutUsViewController.h"
#import "SetPasswordViewController.h"


#import "Activity.h"
@interface SettingsViewController ()
{


    Activity *activity;

}
@end

@implementation SettingsViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self titleSet:@"更多"];
    
    
    _userInfo.text = [NSString stringWithFormat:@"登录号:%@",[appDelegate.appDefault objectForKey:@"Username"]];
    NSLog(@"登陆时候的用户是%@",[appDelegate.appDefault objectForKey:@"Username"]);
    
    
    _cellNameArr = [[NSArray alloc] initWithObjects:@"修改昵称",@"修改密码",@"系统消息",@"关于我们", nil];
    _cellLogoArr = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"更多 (1).png"], [UIImage imageNamed:@"更多 (2).png"],[UIImage imageNamed:@"更多 (3).png"],[UIImage imageNamed:@"更多 (4).png"],nil];
    
    _tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, 320, 200)];
    _tableList.delegate = self;
    _tableList.dataSource = self;
    _tableList.backgroundColor = [UIColor clearColor];
    _tableList.scrollEnabled = NO;
    [self.view addSubview:_tableList];
//    _tableList.frame = CGRectMake(0, 90, 320, [self tableView:_tableList numberOfRowsInSection:0]*[self tableView:_tableList heightForRowAtIndexPath:0]);
    
    activity = [[Activity alloc] initWithActivity:self.view];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCount1) name:@"changeCount1" object:nil] ;
    
}
-(void)changeCount1
{
   
    

     [self.tableList reloadData];


}
-(void)viewWillAppear:(BOOL)animated
{

    [self.tableList reloadData];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier = [[NSString alloc] initWithFormat:@"settingIdentifier"];
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.statusLabel.backgroundColor = [UIColor clearColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.logoImage.image = [_cellLogoArr objectAtIndex:[indexPath row]];
    cell.nameLabel.text = [_cellNameArr objectAtIndex:[indexPath row]];
    cell.backgroundColor = [UIColor whiteColor];
    
//    UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-25,25, 10, 13)];
//    [accessoryView setImage:[UIImage imageNamed:@"greenjiantou.png"]];
//    [cell addSubview:accessoryView];
    
    
    //修改昵称和系统消息的cell稍有不同
    if ([indexPath row] == 0) {
        
        if (![[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@Appel_self",[appDelegate.appDefault objectForKey:@"Username"]]]  isEqual: @""] && [appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@Appel_self",[appDelegate.appDefault objectForKey:@"Username"]]])
        {
            cell.statusLabel.text = [NSString stringWithFormat:@"%@",[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@Appel_self",[appDelegate.appDefault objectForKey:@"Username"] ]]];
            cell.statusLabel.textAlignment = NSTextAlignmentCenter;

        }
        else
        {
        
            cell.statusLabel.text = @"无";
            cell.statusLabel.textAlignment = NSTextAlignmentCenter;


        
        }
    }
    else if([indexPath row] == 2)
    {
        if ([[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@#",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count] > 0)
        {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"信息提示背景.png"]];
            cell.statusLabel.frame = CGRectMake(230, 18, 24, 24);
            cell.statusLabel.textAlignment = NSTextAlignmentCenter;
            cell.statusLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@#",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count]];
        }
        else if([[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@#",[[NSUserDefaults standardUserDefaults] objectForKey:@"Username"]]] count] == 0)
        {
            cell.statusLabel.hidden = YES;
        }
    }
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;


}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ChaneNickNameViewController *changeNick = [[ChaneNickNameViewController alloc] init];
    ChangePasswordViewController *changePass = [[ChangePasswordViewController alloc] init];
    MessagViewController *message = [[MessagViewController alloc ] init];
    AboutUsViewController *about = [[AboutUsViewController alloc] init];
    
    if (indexPath.row == 0)
    {
        
        [self.navigationController pushViewController:changeNick animated:YES];
    }
    else if(indexPath.row == 1)
    {
          [self.navigationController pushViewController:changePass animated:YES];
    }
    else if(indexPath.row == 2)
    {
        [message getBackName:(^(NSString *str)
                                {
                                    [((ListCell *)[tableView cellForRowAtIndexPath:indexPath]).statusLabel setHidden:YES];
                                })];
        [self.navigationController pushViewController:message animated:YES];
    
    }
    else if(indexPath.row ==3)
    {

        [self.navigationController pushViewController:about animated:YES];
    }
    
   
    
    


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
   
    
}


- (void)viewDidUnload {
    [self setUserInfo:nil];
    [self setLogOutBtn:nil];
    [self setTableList:nil];
    [super viewDidUnload];
}
- (IBAction)logOut:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出登录吗" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 1000;
    [alert show];
    
 }
#pragma mark -
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
    
    if (buttonIndex==0)
    {
        [activity start];
        
        NSLog(@"token is %@",[appDelegate.appDefault objectForKey:@"Token"]);
        
        
        BOOL result = [appDelegate.webInfoManger UserLogoutUsingToken:[appDelegate.appDefault objectForKey:@"Token"]];
        if(result)
        {
             [activity stop];
            
            if (![[appDelegate.appDefault objectForKey:@"Password"] isEqualToString:@""])
            {
                [appDelegate.appDefault setObject:@"" forKey:@"Username"];
                [appDelegate.appDefault setObject:@"" forKey:@"Password"];
                [NOTICECENTER postNotificationName:@"MoveToLogin" object:nil];
            }
            else
            {
                
                SetPasswordViewController *setPass = [[SetPasswordViewController alloc] init];
                [self.navigationController pushViewController:setPass animated:YES];
            }
            
            
        }
        else
        {
            [activity stop];
            
            [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
            
        }
    
        
    }
        
    }
    
}


@end
