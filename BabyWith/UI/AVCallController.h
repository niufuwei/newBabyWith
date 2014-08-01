//
//  AVCallController.h
//  BabyWith
//
//  Created by laoniu on 14-8-1.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AVCallController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    //UI
    UILabel*labelState;
    UIButton*btnStartVideo;
    UIView*localView;
    
    AVCaptureSession* avCaptureSession;
    AVCaptureDevice *avCaptureDevice;
    BOOL firstFrame; //是否为第一帧
    int producerFps;
    
    
}
@property (nonatomic, retain) AVCaptureSession *avCaptureSession;
@property (nonatomic, retain) UILabel *labelState;


- (void)createControl;
- (AVCaptureDevice *)getFrontCamera;
- (void)startVideoCapture;
- (void)stopVideoCapture:(id)arg;

@end
