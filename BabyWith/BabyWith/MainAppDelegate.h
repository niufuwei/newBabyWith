//
//  ABCAppDelegate.h
//  BabyWith
//
//  Created by wangminhong on 13-6-25.
//  Copyright (c) 2013年 shancheng.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPPP_API.h"
#import "PPPPChannel.h"
#import "PPPPDefine.h"
//#import "PPPPChannelManagement.h"
#import "BabyWithCameraManagement.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#include<stdlib.h>
#import <AVFoundation/AVFoundation.h>

//#import <AudioToolbox/AudioToolbox.h>

@class WebInfoManager;
@class SQLiteManager;
@class DeviceConnectManager;
@class LoginViewController;


@interface MainAppDelegate : UIResponder <UIApplicationDelegate,MBProgressHUDDelegate,PPPPSensorAlarmProtocol,AlarmProtocol>{
    
    UIWindow *_window;
    NSUserDefaults *_appDefault;                       //UserDefault
    WebInfoManager *_webInfoManager;
    SQLiteManager *_sqliteManager;
    DeviceConnectManager *_deviceConnectManager;
    LoginViewController *_loginViewController;
    UINavigationController *_navController;
    NSMutableArray *_messageArray;
//    CPPPPChannelManagement *_m_PPPPChannelMgt;
    BabyWithCameraManagement *_m_PPPPChannelMgt;
    NSMutableDictionary *_recordMutableDictionary;
    
    NSMutableArray *_recordLocalYearCountArray;
    NSMutableDictionary *_recordLocalMonthCountDic;
    NSMutableDictionary *_recordLocalYearMonthListDic;
    NSMutableDictionary *_recordLocalDayListDic;
    NSMutableDictionary *_recordLocalDayCountDic;
    
    NSOperationQueue *_recordOperationQueue;
    NetworkStatus _networkStatus;
    int _navFlag;
    
    
    
    NSMutableArray *_selectDeviceArr;
    NSMutableArray *_systemMessageArray;
    
    
    NSTimer *_messageTimer;
    
    AVAudioPlayer  *_avAudioPlayer;
    
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,assign) NSUserDefaults *appDefault;
@property (nonatomic,assign) WebInfoManager *webInfoManger;
@property (nonatomic,assign) SQLiteManager *sqliteManager;
@property (nonatomic,assign) DeviceConnectManager *deviceConnectManager;
@property (nonatomic,retain) NSMutableArray *messageArray;
//@property  CPPPPChannelManagement* m_PPPPChannelMgt;
@property BabyWithCameraManagement *m_PPPPChannelMgt;
@property (nonatomic,retain) NSMutableDictionary *recordMutableDictionary;
@property (nonatomic,retain) NSMutableArray *recordLocalYearCountArray;
@property (nonatomic,retain) NSMutableDictionary *recordLocalMonthCountDic;
@property (nonatomic,retain) NSMutableDictionary *recordLocalYearMonthListDic;
@property (nonatomic,retain) NSMutableDictionary *recordLocalDayCountDic;
@property (nonatomic,retain) NSMutableDictionary *recordLocalDayListDic;
@property (nonatomic,assign) NetworkStatus networkStatus;
@property (nonatomic,assign) int navFlag;
@property (nonatomic,retain) NSTimer *messageTimer;
@property (nonatomic,retain) NSString *deviceToken;
@property (nonatomic,retain)  NSMutableDictionary * systemDic;
@property (nonatomic,retain)  NSMutableDictionary * pushDic;

@property (nonatomic,retain) NSMutableArray *selectDeviceArr;
@property (nonatomic,retain)NSMutableArray *systemMessageArray;
@property (nonatomic,strong) AVAudioPlayer  *avAudioPlayer;;

//风火轮委托
- (void)showWithLabel:(NSString *)title;
- (void)endHud;

@end
