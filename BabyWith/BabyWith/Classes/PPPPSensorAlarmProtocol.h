//
//  PPPPSensorAlarmProtocol.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-5-23.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2P_API_Define.h"
@protocol PPPPSensorAlarmProtocol <NSObject>
- (void) PPPPSensorAlarm:(NSString*) strDid andSensorInfo:(STRU_SENSOR_ALARM_INFO)  sensorInfo;

@end
