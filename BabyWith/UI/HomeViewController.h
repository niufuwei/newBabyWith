//
//  HomeViewController.h
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeViewController : BaseViewController<UITabBarDelegate ,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

{

    UITableView *_homeTableView1;
    NSMutableDictionary *_willDeleteDevice;
    NSCondition *_m_PPPPChannelMgtCondition;
    
    int _finishFlag;   //为0连接成功   1未成功
    int _stopConnectFlag;   //1是未停止连接  0是连接成功
    int _passwordFlag;//是否使用初始密码连接过 0：没有  1：有
    NSString * _errorMsg;
    int _switchFlag;
    int _errorFlag;
    int _wifiFlag;
    
    NSMutableDictionary * deviceDic;
    
    NSString *_cameraID;
    NSString * tempState;
    
    NSInteger currentDevice;
    BOOL mycontinue;
    NSMutableDictionary * currentDic;
    int _currentRow;
    
    UILabel * tuisongLabel;
    UIImageView *titleImage;
}


@end
