//
//  CameraSetWifiViewController.h
//  BabyWith
//
//  Created by wangminhong on 13-9-1.
//  Copyright (c) 2013年 shancheng.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PPPP_API.h"
#include "PPPPChannel.h"
#include "PPPPDefine.h"

@interface CameraSetWifiViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate,WifiParamsProtocol>
{
    UITableView *_wifiListTableView;
    NSMutableArray *_wifiSearchList;
    
    NSObject *_delegate;
    NSInteger lastSelectRow;
}

- (id)initWithDelegate:(NSObject *)delegate;

@end
