//
//  NextForgotPasswordViewController.h
//  BabyWith_
//
//  Created by shanchen on 14-3-12.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"

@interface NextForgotPasswordViewController : BaseViewController<UITextFieldDelegate>

{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *getCheckCodeButton;

- (IBAction)showPassWordBtn:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (strong,nonatomic) NSString *configPhoneNum;
- (IBAction)getCheckCode:(id)sender;

- (IBAction)submit:(id)sender;
@end
