//
//  ChaneNickNameViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ChaneNickNameViewController.h"
#import "WebInfoManager.h"
#import "MainAppDelegate.h"
#import "Configuration.h"
#import "Activity.h"
@interface ChaneNickNameViewController ()
{

    Activity *activity;


}
@end

@implementation ChaneNickNameViewController

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
    //圆角
    self.nickName.layer.cornerRadius = 1.5;
    

    [self titleSet:@"修改昵称"];
    
    UIButton * subMit = [[UIButton alloc] initWithFrame:CGRectMake(50, 150, 220, 35)];
    [subMit setBackgroundImage:[UIImage imageNamed:@"qietu_146.png"] forState:UIControlStateNormal];
//    [subMit setTitleColor:babywith_text_background_color forState:UIControlStateNormal];
//    [subMit setBackgroundColor:babywith_green_color];
//    [subMit.layer setMasksToBounds:YES];
//    [subMit.layer setCornerRadius:5.0];
    [subMit addTarget:self action:@selector(submitNickName:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:subMit];
    
    
    
    
    activity = [[Activity alloc] initWithActivity:self.view];


}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    [_nickName becomeFirstResponder];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}


- (void)viewDidUnload {
    [self setNickName:nil];
    [super viewDidUnload];
}


- (IBAction)submitNickName:(id)sender {
    
    
    if ([_nickName.text isEqualToString:@""])
    {
        [self makeAlert:@"昵称不可为空"];
    }
    else
    {
        [activity start];
        BOOL result = [appDelegate.webInfoManger UserModifyAppelUsingAppel:_nickName.text Toekn:[appDelegate.appDefault objectForKey:@"Token"]];
        if (result)
        {
            
            [activity stop];
            UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
            indicator.labelText = @"修改成功";
            indicator.mode = MBProgressHUDModeText;
            [window addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                sleep(1.2);
            } completionBlock:^{
                [indicator removeFromSuperview];
                [appDelegate.appDefault setObject:_nickName.text forKey:[NSString stringWithFormat:@"%@Appel_self",[appDelegate.appDefault objectForKey:@"Username"]]];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [activity stop];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate.appDefault objectForKey:@"提示"] message:[appDelegate.appDefault objectForKey:@"Error_message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            alert.tag = 2048;
            [alert show];

        }
        
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 2048)
    {
        if ([[appDelegate.appDefault objectForKey:@"login_expired"] isEqualToString:@"1"])
        {
            [appDelegate.appDefault setObject:@"" forKey:@"Username"];
            [appDelegate.appDefault setObject:@"" forKey:@"Password"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MoveToLogin" object:nil];
        }
        else
        {
            
            NSLog(@"没有被踢");
            
        }
        
    }
    
    
}

@end
