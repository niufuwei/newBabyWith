//
//  ShareDeviceViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ShareDeviceViewController.h"
#import "WebInfoManager.h"
#import "MainAppDelegate.h"
#import "Activity.h"




@interface ShareDeviceViewController ()
{


    Activity *activity;

}
@end

@implementation ShareDeviceViewController

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
    
    
    //左导航-主选择页面
    UIButton *navButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 35)];
    [navButton setImage:[UIImage imageNamed:@"camera_back"] forState:UIControlStateNormal];
    [navButton addTarget:self action:@selector(pop:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView: navButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    self.title  = @"分享账号";
    
    //圆角
    self.phoneNumber.layer.cornerRadius=2.0;
    
    // Do any additional setup after loading the view from its nib.
     _submit= [[UIButton alloc] initWithFrame:CGRectMake(50, 123, 220, 35)];
    [_submit setBackgroundImage:[UIImage imageNamed:@"qietu_146.png"] forState:UIControlStateNormal];
//    [_submit setTitleColor:babywith_text_background_color forState:UIControlStateNormal];
//    [_submit setBackgroundColor:babywith_green_color];
//    [_submit.layer setMasksToBounds:YES];
//    [_submit.layer setCornerRadius:3.0];
    [_submit addTarget:self action:@selector(submitBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    [self.view addSubview:_submit];
    self.phoneNumber.delegate = self;
    
    

}

-(void)pop:(id )sender

{
    [self.navigationController popViewControllerAnimated:YES];
    
    [appDelegate.selectDeviceArr removeAllObjects];
}


//添加通讯录
- (IBAction)AddAdressBtn:(id)sender {
    
    
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self.navigationController presentViewController:peoplePicker animated:YES completion:nil];
    
    
}
#pragma mark - 
#pragma mark ABPeoplePickerNavigationControllerDelegate
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if (property == kABPersonPhoneProperty) {
        
        ABMutableMultiValueRef phoneMulti = ABRecordCopyValue(person, property);
        
        
        
        int index = ABMultiValueGetIndexForIdentifier(phoneMulti,identifier);
        
        
        
//        NSString *phone = (NSString*)ABMultiValueCopyValueAtIndex(phoneMulti, index);
//        NSLog(@">>><<<<>>><>%@",ABMultiValueCopyLabelAtIndex(phoneMulti, index));
        NSString *phone = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phoneMulti, index);
        NSLog(@">>>>>%@",phone);
        //do something
    
        
        
        self.phoneNumber.text = phone;
        
        
        

        
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        
        
        
    }
    
    
    
    return NO;
    

}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker

{
    
    // assigning control back to the main controller
    
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:YES];
    [self.phoneNumber becomeFirstResponder];


}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    self.phoneNumber.keyboardType = UIKeyboardTypeNumberPad;




}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    [self setPhoneNumber:nil];
    [self setSubmit:nil];
    [super viewDidUnload];
}
- (void)submitBtn:(id)sender
{
    
    [self.phoneNumber endEditing:YES];
    
    activity = [[Activity alloc] initWithActivity:self.view];

    _submit.enabled = NO;
    self.phoneNumber.text = [self.phoneNumber.text
                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"<><><><><><><><><>%@",self.phoneNumber.text);
    
    //检查电话号码是否符合规格
    int phone_email_flag = [self checkTel:self.phoneNumber.text Type:1];
    NSLog(@"%d",phone_email_flag);
    if (phone_email_flag == 0 )
    {
        _submit.enabled = YES;
        [activity stop];
        return;
    }
    
    
    
    //设备ID以逗号隔开
    NSString * deviceID;
    int i = [appDelegate.selectDeviceArr count];
    NSLog(@">>>>>>>>%d",i);
    //NSLog(@">>>>>>>>%@",[[appDelegate.selectDeviceArr objectAtIndex:0] objectForKey:@"device_id"]);
    
    deviceID =  [[appDelegate.selectDeviceArr objectAtIndex:0] objectForKey:@"device_id"];
    //一开始始终是取得第一个
    //这个device id需要用逗号隔开
     if(i > 1 )
     {
        for (int m = 1; m < i; m++)
        {
            deviceID = [NSString stringWithFormat:@"%@,%@",deviceID,[[appDelegate.selectDeviceArr objectAtIndex:m] objectForKey:@"device_id"]];
        }
    
    
    }
    
    
    [activity start];

    BOOL result = [appDelegate.webInfoManger UserShareDeviceUsingDeviceID:deviceID Phone:_phoneNumber.text Token:[appDelegate.appDefault objectForKey:@"Token"] PhoneType:@"2"];
     if (result)
    {
        

        
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:[[UIApplication sharedApplication].windows count]-1];
        MBProgressHUD *indicator = [[MBProgressHUD alloc] initWithWindow:window];
        indicator.labelText = @"分享成功";
        indicator.mode = MBProgressHUDModeText;
        [window addSubview:indicator];
        [indicator showAnimated:YES whileExecutingBlock:^{
            sleep(1.2);
        } completionBlock:^{
            [indicator removeFromSuperview];
            
            [activity stop];

            //选择的设备的数量
            int i = [appDelegate.selectDeviceArr count];
            NSLog(@"选择的设备的数量是%d",i);
            
            
            for (int n = 1; n <= i; n++)
            {
                
                
                NSLog(@"设备的分享人员是%@",[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex:n - 1] objectForKey:@"device_id"]]]);
                
                NSLog(@"这里走了没");
                //如果这个key不存在，就创建这个key
                if (![appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex:n - 1] objectForKey:@"device_id"]]])
                {   //第一次创建的时候直接添加就行
                    [appDelegate.appDefault setObject:self.phoneNumber.text forKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex:n - 1] objectForKey:@"device_id"]]];
                    
                }
                else//如果对应的key里面有值(array),那就往这个array里面添加
                {
                    NSMutableArray *array1 =[[NSMutableArray alloc] initWithArray: [appDelegate.appDefault arrayForKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex: n -1] objectForKey:@"device_id"]]]];
                    //把array里面的所有元素添加到新的array1里面
                    NSLog(@"array1----------- is %d---------------",[array1 count]);
                    
                    if ([array1 containsObject:self.phoneNumber.text] == NO)
                    {
                        
                        [array1 addObject:self.phoneNumber.text];
                    }
                    
                    
                    NSLog(@"array1----------- is %d---------------",[array1 count]);

                    NSArray *array2 = [NSArray arrayWithArray:array1];
                    [appDelegate.appDefault setObject:array2 forKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex: n - 1] objectForKey:@"device_id"]]];
                    
                    
                    NSLog(@"分享人员的名单是 %@",[appDelegate.appDefault objectForKey:[NSString stringWithFormat:@"%@_number",[[appDelegate.selectDeviceArr objectAtIndex:n -1] objectForKey:@"device_id"]]]);
                }
            }
            _submit.enabled = YES;
            [appDelegate.selectDeviceArr removeAllObjects];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    }
    else
    {
        [activity stop];
        _submit.enabled = YES;
        //[self makeAlertForServerUseTitle:[appDelegate.appDefault objectForKey:@"Error_message"] Code:[appDelegate.appDefault objectForKey:@"Error_code"]];
        
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
//-(void)viewWillDisappear:(BOOL)animated
//{
//
//
//
//}


@end
