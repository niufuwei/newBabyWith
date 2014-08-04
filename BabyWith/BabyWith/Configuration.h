//
//  Configuration.h
//  AiJiaJia
//
//  Created by wangminhong on 13-4-14.
//  Copyright (c) 2013年 shancheng.com. All rights reserved.
//

#ifndef AiJiaJia_Configuration_h
#define AiJiaJia_Configuration_h

@class MainAppDelegate;

#define appDelegate ((MainAppDelegate*)[[UIApplication sharedApplication] delegate])
#define IOS7 ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0)
#define ClientVersion @"5"
//#define babywith_gate_address  @"http://www.chaoyongwenhua.com:8080/aiJIaJIaWebservice/api"
//#define babywith_gate_address @"http://192.168.18.105:8081/aiJIaJIaWebservice/api"
#define babywith_background_color babywith_color(0xf5f5f5)
#define babywith_gate_address @"http://192.168.18.159:8081/aiJIaJIaWebservice/api"
#define babywith_text_background_color [UIColor colorWithRed:253/255.0 green:251/255.0 blue:249/255.0 alpha:1.0]
#define babywith_text_color [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1.0]
#define babywith_button_text_color [UIColor colorWithRed:98/255.0 green:98/255.0 blue:98/255.0 alpha:1.0]
#define babywith_green_color [UIColor colorWithRed:106/255.0 green:202/255.0 blue:154/255.0 alpha:1.0]
#define babywith_green_color_hightlight [UIColor colorWithRed:147/255.0 green:213/255.0 blue:176/255.0 alpha:1.0]
#define babywith_orange_color [UIColor colorWithRed:242/255.0 green:142/255.0 blue:115/255.0 alpha:1.0]
#define babywith_orange_color_hightlight [UIColor colorWithRed:247/255.0 green:196/255.0 blue:182/255.0 alpha:1.0]
#define babywith_color(rgbValue)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



#define babywith_sandbox_address [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"babywith"]
#define kAlphaNum   @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define DeviceInitUser @"admin"
#define DeviceInitPass @"888888"
#define KeyFrameLenth 1382400
#define KeyFrameWidth 1280
#define KeyFrameHeight 720
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#endif
