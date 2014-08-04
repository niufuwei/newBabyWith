//
//  AVCallController.h
//  BabyWith
//
//  Created by laoniu on 14-8-1.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ImagePickerControllerDelegate <NSObject>

-(void)cameraPhoto:(NSArray*)imageArra;

@end
@interface AVCallController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate>
{
    //UI
    UILabel*labelState;
    UIButton*btnStartVideo;
    UIView*localView;
    
    AVCaptureSession* avCaptureSession;
    AVCaptureDevice *avCaptureDevice;
    BOOL firstFrame; //是否为第一帧
    int producerFps;
    BOOL isStop;
    UIImageView * SaveImage;
    UIButton *imageButton;
    BOOL isBackFront;
    AVAudioPlayer *_avAudioPlayer;
    NSMutableArray * _imageArray;
    
}


@property (nonatomic, retain) AVCaptureSession *avCaptureSession;
@property (nonatomic, retain) UILabel *labelState;
@property(nonatomic,assign)id<ImagePickerControllerDelegate> customDelegate;

- (void)createControl;
- (AVCaptureDevice *)getFrontCamera;
- (void)startVideoCapture;
- (void)stopVideoCapture:(id)arg;

@end
