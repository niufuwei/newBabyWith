//
//  ChangePasswordViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UIViewController+Alert.h"
#import "MainAppDelegate.h"
#import "WebInfoManager.h"
#import "Activity.h"
@interface ChangePasswordViewController ()
{


    Activity *activity;
}


@property (nonatomic) BOOL keyboardShowed;

@end

@implementation ChangePasswordViewController

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
    
    
//     _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 60, 92, 30)];
//    [_firstBtn setTitle:@"显示密码" forState:UIControlStateNormal];
//    [_firstBtn setTitleColor:babywith_text_background_color forState:UIControlStateNormal];
//    [_firstBtn setBackgroundColor:babywith_green_color];
//    [_firstBtn.layer setMasksToBounds:YES];
//    [_firstBtn.layer setCornerRadius:5.0];
//    [_firstBtn addTarget:self action:@selector(showPass1:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_firstBtn];
//    
//    
//    _secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 108, 92, 30)];
//    [_secondBtn setTitle:@"显示密码" forState:UIControlStateNormal];
//    [_secondBtn setTitleColor:babywith_text_background_color forState:UIControlStateNormal];
//    [_secondBtn setBackgroundColor:babywith_green_color];
//    [_secondBtn.layer setMasksToBounds:YES];
//    [_secondBtn.layer setCornerRadius:5.0];
//    [_secondBtn addTarget:self action:@selector(showPass2:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_secondBtn];
    
   //圆角
    self.oldPass.layer.cornerRadius = 1.5;
    self.freshPass.layer.cornerRadius = 1.5;
    
     [self titleSet:@"修改密码"];
    _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 165, 220, 35)];
    [_submitBtn setBackgroundImage:[UIImage imageNamed:@"qietu_146.png"] forState:UIControlStateNormal];
//    [_submitBtn setTitleColor:babywith_text_background_color forState:UIControlStateNormal];
//    [_submitBtn setBackgroundColor:babywith_green_color];
//    [_submitBtn.layer setMasksToBounds:YES];
//    [_submitBtn.layer setCornerRadius:5.0];
    [_submitBtn addTarget:self action:@selector(submitChange:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
    
    
    
    
   
    
    
    _oldPass.delegate = self;
    _oldPass.secureTextEntry = YES;
    _freshPass.delegate = self;
    _freshPass.secureTextEntry = YES;
    
    
    
    activity = [[Activity alloc] initWithActivity:self.view];
    
   
}

//显示密码按钮

- (IBAction)displayBtn:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    
    if (_oldPass.secureTextEntry == NO)
    {
        _oldPass.secureTextEntry = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"选择 (1).png"] forState:UIControlStateNormal];
        
    }
    else
    {
        _oldPass.secureTextEntry = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"选择 (2).png"] forState:UIControlStateNormal];
        
    }
    
    
    if (_freshPass.secureTextEntry == NO)
    {
        _freshPass.secureTextEntry = YES;
       
        [btn setBackgroundImage:[UIImage imageNamed:@"选择 (1).png"] forState:UIControlStateNormal];
    }
    else
    {
        _freshPass.secureTextEntry = NO;
         [btn setBackgroundImage:[UIImage imageNamed:@"选择 (2).png"] forState:UIControlStateNormal];
    }


}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    [_oldPass becomeFirstResponder];



}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    [_oldPass resignFirstResponder];
    [_freshPass resignFirstResponder];
    
//    if (!_keyboardShowed) {
//        return;
//    }
//    [_oldPass resignFirstResponder];
//    [_freshPass resignFirstResponder];
    
//    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
//        if (IOS7)
//        {
//            self.view.frame = CGRectMake(0, 44 + 20, 320, kScreenHeight -44 -20);
//            
//        }
//        else
//        {
//            self.view.frame = CGRectMake(0, 0, 320, kScreenHeight -44 -20);
//            
//        }    } completion:^(BOOL finished) {
//        _keyboardShowed = NO;
//    }];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    _freshPass.keyboardType = UIKeyboardTypeASCIICapable;
    _oldPass.keyboardType = UIKeyboardTypeASCIICapable;
    
//    
//    if (_keyboardShowed)
//    {
//        return;
//    }
//    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
//        
//        if (IOS7)
//        {
//            self.view.frame = CGRectMake(0, 10, 320, kScreenHeight -44 -20);
//            
//        }
//        else
//        {
//            self.view.frame = CGRectMake(0, -25, 320, kScreenHeight -44 -20);
//            
//        }
//        
//    } completion:^(BOOL finished) {
//        _keyboardShowed = YES;
//    }];
    
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if (_keyboardShowed) {
//        return;
//    }
//    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
//        
//        if (IOS7)
//        {
//            self.view.frame = CGRectMake(0, 44 + 20, 320, kScreenHeight -44 -20);
//            
//        }
//        else
//        {
//            self.view.frame = CGRectMake(0, 0, 320, kScreenHeight -44 -20);
//            
//        }
//        
//    } completion:^(BOOL finished) {
//        _keyboardShowed = NO;
//    }];
    
    
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



- (void)submitChange:(id)sender {
    
    _oldPass.text = [_oldPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    _freshPass.text = [_freshPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if ([_freshPass.text isEqualToString:@""])
    {
        [self makeAlert:@"密码不可为空"];
        return;
    }
    if ([_freshPass.text length]<6 ||[_freshPass.text length]>12) {
        [self makeAlert:@"密码长度限制为6-12位"];
        return;
    }
    //原来没有设置密码的话就是@"",可以不填写
    if (![_oldPass.text isEqualToString:[appDelegate.appDefault objectForKey:@"Password"]])
    {
        [self makeAlert:@"原密码错误"];
        return;
    }
    
   
    
    [activity start];
    BOOL result = [appDelegate.webInfoManger UserModifyPasswordUsingToken:[appDelegate.appDefault objectForKey:@"Token"] Password:_oldPass.text NewPassword:_freshPass.text];
    if (result)
    {
        [activity stop];
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"密码修改成功";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
            _oldPass.text = @"";
            _freshPass.text = @"";
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
