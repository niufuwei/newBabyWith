//
//  ChangePasswordViewController.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"

@interface ChangePasswordViewController : BaseViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UITextField *oldPass;
@property (retain, nonatomic) IBOutlet UITextField *freshPass;
@property (retain, nonatomic)  UIButton *submitBtn;
- (IBAction)displayBtn:(id)sender;

@end
