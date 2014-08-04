//
//  AddDeviceViewController.h
//  SkyEye
//
//  Created by shanchen on 14-7-8.
//  Copyright (c) 2014年 kang_dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "SearchDVS.h"
#import "BaseViewController.h"

@interface AddDeviceViewController : BaseViewController
<UIAlertViewDelegate,ZBarReaderDelegate,AVCaptureMetadataOutputObjectsDelegate,UITableViewDataSource,UITableViewDelegate,SearchCameraResultProtocol>

{
    UIAlertView *alert;
    NSMutableArray *_cameraSearchList;
    
    BOOL isOn;//手电筒
    UIButton *setButton;
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    UILabel * _labIntroudction;
    UIImageView * _imageView;
    
    NSInteger btnIndex;
    UITextField * txt;
    UITextField *tf;
    BOOL isFirst;
    
    UIView *inputView;
    UIView *deviceListView;
    UITableView *deviceListTableView;
    
    CSearchDVS  *_pSearchDVS;
    
    NSMutableArray *_alreadyGotDeviceIdArr;
    NSMutableArray *_searchDeviceIdArr;

    BOOL loadDevice;

}

@property(retain,nonatomic)AVCaptureSession *session;
@property(retain,nonatomic)  AVCaptureVideoPreviewLayer *previewLayer;
@property(retain,nonatomic)UIImageView *line;



@end
