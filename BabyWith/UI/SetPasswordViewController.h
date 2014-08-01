//
//  SetPasswordViewController.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-19.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"

@interface SetPasswordViewController : BaseViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UITextField *passwordField;

@property (retain, nonatomic) IBOutlet UIButton *submit;

- (IBAction)submitPass:(id)sender;


- (IBAction)displayPassBtn:(id)sender;


@end
