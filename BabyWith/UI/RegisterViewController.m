//
//  RegisterViewController.m
//  BabyWith
//
//  Created by shanchen on 14-3-11.
//  Copyright (c) 2014年 shancheng.com. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "WebInfoBinding.h"
#import "WebInfoManager.h"
#import "MainAppDelegate.h"
#import <AdSupport/ASIdentifierManager.h>
#import "CameraAddingViewController.h"
#import "Activity.h"

@interface RegisterViewController ()
{

    Activity *activity ;

}

@property (nonatomic) BOOL keyboardShowed;

@end

@implementation RegisterViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self titleSet:@"babywith"];
//    [self configurationForGreenButton:_registerButton];
    self.navigationController.navigationBarHidden = YES;
    
    //顶部字体图片
    UIImageView *fontImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 60, 180, 50)];
    fontImage.image = [UIImage imageNamed:@"qietu_267.png"];
    [self.view addSubview:fontImage];
    //label
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height-295, 280, 20)];
    aLabel.text = @"注册您babywith的第一个账号";
    aLabel.textColor = [UIColor whiteColor];
    aLabel.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:aLabel];
    //手机号码
    
    phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 215, aLabel.frame.size.height+10, 35)];
    phoneTF.layer.cornerRadius = 1.5;
    phoneTF.placeholder = @"手机号码";
    [self.view addSubview:phoneTF];
    
    //确认手机号码
    confirmTF = [[UITextField alloc] initWithFrame:CGRectMake(20, 215, aLabel.frame.size.height+10+37, 35)];
    confirmTF.layer.cornerRadius = 1.5;
    confirmTF.placeholder = @"确认手机号码";
    [self.view addSubview:confirmTF];
    
    //下一步
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(50, aLabel.frame.size.height+80, 220, 35);
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    //跳过注册
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finshBtn.frame = CGRectMake(70, aLabel.frame.size.height+100, 180, 30);
    [finshBtn addTarget:self action:@selector(finshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    

    
    
    activity = [[Activity alloc] initWithActivity:self.view];
    
    
    NSLog(@"是否是第一次登陆%@",[USRDEFAULT objectForKey:@"First_use_flag"]);


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    }

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_keyboardShowed) {
        return;
    }
    [phoneTF resignFirstResponder];
    [confirmTF resignFirstResponder];
    
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, 0, 320, kScreenHeight -44 -20);
    } completion:^(BOOL finished) {
        _keyboardShowed = NO;
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_keyboardShowed) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, -100, 320, kScreenHeight -44 -20);
    } completion:^(BOOL finished) {
        _keyboardShowed = YES;
    }];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_keyboardShowed) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.view.frame = CGRectMake(0, 0, 320, kScreenHeight -44 -20);
    } completion:^(BOOL finished) {
        _keyboardShowed = NO;
    }];
    
}

- (IBAction)skipRegistration:(UIButton *)sender {
    LoginViewController *vc = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    //[NOTICECENTER postNotificationName:@"MoveToMain" object:nil];
}

- (IBAction)startRegister:(UIButton *)sender {
    //校验手机号码

    NSString *phoneStr = [phoneTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int phone_email_flag = [self checkTel:phoneStr Type:1];
    if (phone_email_flag == 0) {
        return;
    }
    if (![phoneStr isEqualToString:[confirmTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
        [self makeAlert:@"确认号码不一致"];
        return;
    }
    //注册
    [self macAddressGet];
    
    
    [activity start];
    
    BOOL result = [appDelegate.webInfoManger UserRegisterUsingUser:phoneStr Vesting:@"86" RefistType:@"1" Password:@"" Mac:[appDelegate.appDefault objectForKey:@"Mac_self"]];

    
        if (result) {
            
            
            
            UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
            MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
            indicator.labelText = @"注册成功";
            indicator.mode = MBProgressHUDModeText;
            [window addSubview:indicator];
            [indicator showAnimated:YES whileExecutingBlock:^{
                sleep(1.2);
            } completionBlock:^{
                [indicator removeFromSuperview];
                [USRDEFAULT setInteger:1 forKey:@"First_use_flag"];
                if (result) {

                    
                    
                    //登陆校验，发送消息到服务器
                    BOOL result = [appDelegate.webInfoManger UserLoginUsingUsername:phoneTF.text Password:@"" Version:ClientVersion Vesting:@"86" ClientType:@"2" DeviceToken:appDelegate.deviceToken];
                    
                    if (result)
                    {
                        [activity stop];
                        [appDelegate.appDefault setObject:@"0" forKey:@"login_expired"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"MoveToMain" object:nil];
                        
                    }
                    

                }else{ //错误判断 如果是版本更新TODO

                    [activity stop];

                    [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
                }
            }];
        }else{
            
            

            [activity stop];
            
            [self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
        }
    
}


- (void)macAddressGet
{
    //本机MAC地址
    if (IOS7) {
        [appDelegate.appDefault setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forKey:@"Mac_self"];
    }else{
        NSString *mac = [self getLocalMacAddress];
        [appDelegate.appDefault setValue:mac forKey:@"Mac_self"];
    }
}
@end
