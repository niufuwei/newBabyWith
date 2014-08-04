//
//  NextForgotPasswordViewController.m
//  BabyWith_
//
//  Created by shanchen on 14-3-12.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "NextForgotPasswordViewController.h"
#import "MainAppDelegate.h"
#import "WebInfoManager.h"
#import "UIViewController+Alert.h"
#import "HomeViewController.h"
#import "Activity.h"
@interface NextForgotPasswordViewController ()
{

    
    Activity *activity;


}
@property (nonatomic) BOOL isShowing;

@end

@implementation NextForgotPasswordViewController

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
    
     [self titleSet:@"找回密码"];
    
    _isShowing = NO;
    _passwordTF.secureTextEntry = YES;
    _passwordTF.delegate = self;
    
//    [self configurationForGreenButton:_getCheckCodeButton];
//    [self configurationForGreenButton:_showPasswordButton];
//    [self configurationForGreenButton:_submitButton];
   // NSLog(@"手机号码是%@",_configPhoneNum);
    
    activity = [[Activity alloc] initWithActivity:self.view];

}
-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    [_checkCodeTF becomeFirstResponder];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
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


    _passwordTF.keyboardType = UIKeyboardTypeASCIICapable;


}
- (IBAction)getCheckCode:(id)sender {
    
//    UIButton *btn = sender;
//    [btn setBackgroundImage:[UIImage imageNamed:@"qietu_254.png"] forState:UIControlStateNormal];
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"sendCheckMessage"] isEqualToString:@"0"]) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(getCheck) userInfo:nil repeats:NO];
        [self sendChekMessage];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"sendCheckMessage"];
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"验证码已发送" message:@"如果尚未收到，请您60秒之后再重新获取" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(void)sendChekMessage
{
    
    [activity start];
    BOOL result = [appDelegate.webInfoManger UserForgetPasswordUsingPhone:_configPhoneNum Vesting:@"86"];
    if (!result)
    {
        [activity stop];
        [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
    }
    else
    {
        [activity stop];
        
        //添加计时器防止不停获取验证码
        
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"验证码已发送";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
        }];
        
    }

}

-(void)getCheck
{
    UIButton *btn = (UIButton *)[self.view viewWithTag:10086];
   [btn setBackgroundImage:[UIImage imageNamed:@"qietu_254.png"] forState:UIControlStateNormal];
   [_timer invalidate];
   [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"sendCheckMessage"];
    
}

//显示密码
- (IBAction)showPassWordBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (_passwordTF.secureTextEntry == YES)
    {
        _passwordTF.secureTextEntry = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"退出系统 -显示密码.png"] forState:UIControlStateNormal];
    }
    else
    {
        _passwordTF.secureTextEntry = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"退出系统-取消显示.png"] forState:UIControlStateNormal];
    }
    
}



- (IBAction)submit:(id)sender {
    
    
    //校检验证码
    _checkCodeTF.text = [_checkCodeTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([_checkCodeTF.text length] == 0) {
        [self makeAlert:@"请输入验证码"];
        return;
    }
    
    if ([_checkCodeTF.text length] != 6 ) {
        [self makeAlert:@"验证码不正确"];
        return;
    }
    
    
    //检查密码是否符合规范
    _passwordTF.text = [_passwordTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_passwordTF.text.length == 0) {
        [self makeAlert:@"请输入密码"];
        return;
    }
    if (_passwordTF.text.length <6 || _passwordTF.text.length>12) {
        [self makeAlert:@"密码长度限制为6-12位"];
        return;
    }
    
    [activity start];
    BOOL result = [appDelegate.webInfoManger UserResetPasswordByPhoneUsingUsername:_configPhoneNum Authcode:_checkCodeTF.text Password:_passwordTF.text];
    if (result) {
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"密码重置成功";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
            //登陆校验，发送消息到服务器
            //这里必须重新调用登陆的方法，因为只有经过这个方法之后才会有返回值，才会有相关的信息
            BOOL result = [appDelegate.webInfoManger UserLoginUsingUsername:self.configPhoneNum Password:self.passwordTF.text Version:ClientVersion Vesting:@"86" ClientType:@"2" DeviceToken:appDelegate.deviceToken];
            
            
            if (result) {
                
                [activity stop];
                [appDelegate.appDefault setObject:@"0" forKey:@"login_expired"];
                //放进数据库，保证下次进来的时候就是最新的用户信息
                [appDelegate.appDefault setObject:self.configPhoneNum forKey:@"Username"];
                [appDelegate.appDefault setObject:self.passwordTF.text forKey:@"Password"];
                
                [NOTICECENTER postNotificationName:@"MoveToMain" object:nil];
            }
            else
            {
                [activity stop];

                //提示框提示错误
                [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
            }
            NSLog(@"%@,,,%@",[appDelegate.appDefault objectForKey:@"Usename"],[appDelegate.appDefault objectForKey:@"Password"]);
                        
        }];
    }else{
        [activity stop];

        [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
    }
    
    
    
}




@end
