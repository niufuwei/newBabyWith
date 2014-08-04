//
//  SetPasswordViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-19.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "SetPasswordViewController.h"
#import "MainAppDelegate.h"
#import "WebInfoManager.h"
#import "Activity.h"
@interface SetPasswordViewController ()
{

    Activity *activity;


}
@end

@implementation SetPasswordViewController

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
    _passwordField.secureTextEntry = YES;
    _passwordField.delegate = self;
    
//    [self configurationForGreenButton:_hidePass];
    [self configurationForGreenButton:_submit];
    
    activity = [[Activity alloc] initWithActivity:self.view];
    //圆角
    self.passwordField.layer.cornerRadius = 1.5;
//    [self.hidePass setTitle:@"隐藏密码" forState:UIControlStateNormal];
//    [self.hidePass setTintColor:[UIColor whiteColor]];
//    [self.hidePass setBackgroundColor:babywith_green_color];
    
//    [self.submit setTitle:@"提交" forState:UIControlStateNormal];
//    [self.submit setTintColor:[UIColor whiteColor]];
//    [self.submit setBackgroundColor:babywith_green_color];


}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
    NSString *filtered =
    [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basic = [string isEqualToString:filtered];
    return basic;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{

    _passwordField.keyboardType = UIKeyboardTypeASCIICapable;


}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    [_passwordField becomeFirstResponder];



}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (void)viewDidUnload {
    [self setPasswordField:nil];
    [self setSubmit:nil];
    [super viewDidUnload];
}

//显示密码
- (IBAction)displayPassBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (_passwordField.secureTextEntry == YES)
    {
        _passwordField.secureTextEntry = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"退出系统 -显示密码.png"] forState:UIControlStateNormal];
    }
    else
    {
        _passwordField.secureTextEntry = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"退出系统-取消显示.png"] forState:UIControlStateNormal];
    }
    
    
}


- (IBAction)submitPass:(id)sender
{
    
    
    _passwordField.text = [_passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
    
    if ([_passwordField.text length]<6 ||[_passwordField.text length]>12) {
        [self makeAlert:@"密码长度限制为6-12位"];
        return;
    }
    
    
    [activity start];
    BOOL result = [appDelegate.webInfoManger UserModifyPasswordUsingToken:[appDelegate.appDefault objectForKey:@"Token"] Password:@"" NewPassword:_passwordField.text];
    if (result){
        
        [activity stop];
        
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"密码设置成功";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
            
            _passwordField.text = @"";
            
            [activity start];
            
            BOOL result = [appDelegate.webInfoManger UserLogoutUsingToken:[appDelegate.appDefault objectForKey:@"Token"]];
            if(result)
            {
                [activity stop];
                    [appDelegate.appDefault setObject:@"" forKey:@"Username"];
                    [appDelegate.appDefault setObject:@"" forKey:@"Password"];
                    [NOTICECENTER postNotificationName:@"MoveToLogin" object:nil];
                           }
            else
            {
                [activity stop];
                
                [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
                
            }
        }];
        
    }else{
        
        [activity stop];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate.appDefault objectForKey:@"提示"] message:[appDelegate.appDefault objectForKey:@"Error_message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alert.tag = 2048;
        [alert show];
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
