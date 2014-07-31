//
//  SettingsViewController.h
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *userInfo;
@property (retain, nonatomic) IBOutlet UIButton *logOutBtn;
@property (retain, nonatomic) UITableView *tableList;
@property (retain, nonatomic) IBOutlet UIView *topView;

@property (nonatomic,retain) NSArray *cellNameArr;
@property (nonatomic,retain) NSArray *cellLogoArr;
@property (nonatomic,assign) int messageCount;

- (IBAction)logOut:(id)sender;
@end
