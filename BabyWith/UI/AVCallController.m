//
//  AVCallController.m
//  BabyWith
//
//  Created by laoniu on 14-8-1.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "AVCallController.h"

@interface AVCallController ()

@end

@implementation AVCallController
@synthesize avCaptureSession;
@synthesize labelState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    if(self= [super init])
    {
        firstFrame= YES;
        producerFps= 50;
    }
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    [self createControl];
}




/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (void)dealloc {
    [super dealloc];
}


#pragma mark -
#pragma mark createControl
- (void)createControl
{
    //UI展示
    self.view.backgroundColor= [UIColor grayColor];
    labelState= [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 220, 30)];
    labelState.backgroundColor= [UIColor clearColor];
    [self.view addSubview:labelState];
    [labelState release];
    
    btnStartVideo= [[UIButton alloc] initWithFrame:CGRectMake(20, 350, 80, 50)];
    [btnStartVideo setTitle:@"Star"forState:UIControlStateNormal];
    
    
    [btnStartVideo setBackgroundImage:[UIImage imageNamed:@"Images/button.png"] forState:UIControlStateNormal];
    [btnStartVideo addTarget:self action:@selector(startVideoCapture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStartVideo];
    [btnStartVideo release];
    
    UIButton* stop = [[UIButton alloc] initWithFrame:CGRectMake(120, 350, 80, 50)];
    [stop setTitle:@"Stop" forState:UIControlStateNormal];
    
    [stop setBackgroundImage:[UIImage imageNamed:@"Images/button.png"] forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(stopVideoCapture:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stop];
    [stop release];
    
    localView= [[UIView alloc] initWithFrame:CGRectMake(40, 50, 200, 300)];
    [self.view addSubview:localView];
    [localView release];
    
    
}
#pragma mark -
#pragma mark VideoCapture
- (AVCaptureDevice *)getFrontCamera
{
    //获取前置摄像头设备
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in cameras)
    {
        if (device.position == AVCaptureDevicePositionBack)
            return device;
    }
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
}
- (void)startVideoCapture
{
    //打开摄像设备，并开始捕抓图像
    [labelState setText:@"Starting Video stream"];
    if(self->avCaptureDevice|| self->avCaptureSession)
    {
        [labelState setText:@"Already capturing"];
        return;
    }
    
    if((self->avCaptureDevice = [self getFrontCamera]) == nil)
    {
        [labelState setText:@"Failed to get valide capture device"];
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self->avCaptureDevice error:&error];
    if (!videoInput)
    {
        [labelState setText:@"Failed to get video input"];
        self->avCaptureDevice= nil;
        return;
    }
    
    self->avCaptureSession = [[AVCaptureSession alloc] init];
    self->avCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
    [self->avCaptureSession addInput:videoInput];
    
    // Currently, the only supported key is kCVPixelBufferPixelFormatTypeKey. Recommended pixel format choices are
    // kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange or kCVPixelFormatType_32BGRA.
    // On iPhone 3G, the recommended pixel format choices are kCVPixelFormatType_422YpCbCr8 or kCVPixelFormatType_32BGRA.
    //
    AVCaptureVideoDataOutput *avCaptureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary*settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                             //[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                             [NSNumber numberWithInt:240], (id)kCVPixelBufferWidthKey,
                             [NSNumber numberWithInt:320], (id)kCVPixelBufferHeightKey,
                             nil];
    avCaptureVideoDataOutput.videoSettings = settings;
    [settings release];
    avCaptureVideoDataOutput.minFrameDuration = CMTimeMake(1, self->producerFps);
    /*We create a serial queue to handle the processing of our frames*/
    dispatch_queue_t queue = dispatch_queue_create("org.doubango.idoubs", NULL);
    [avCaptureVideoDataOutput setSampleBufferDelegate:self queue:queue];
    [self->avCaptureSession addOutput:avCaptureVideoDataOutput];
    [avCaptureVideoDataOutput release];
    dispatch_release(queue);
    
    AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self->avCaptureSession];
    previewLayer.frame = localView.bounds;
    previewLayer.videoGravity= AVLayerVideoGravityResizeAspectFill;
    
    [self->localView.layer addSublayer: previewLayer];
    
    self->firstFrame= YES;
    [self->avCaptureSession startRunning];
    
    [labelState setText:@"Video capture started"];
    
}
- (void)stopVideoCapture:(id)arg
{
    //停止摄像头捕抓
    if(self->avCaptureSession){
        [self->avCaptureSession stopRunning];
        self->avCaptureSession= nil;
        [labelState setText:@"Video capture stopped"];
    }
    self->avCaptureDevice= nil;
    //移除localView里面的内容
    for(UIView*view in self->localView.subviews) {
        [view removeFromSuperview];
    }
}
#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    NSLog(@"获取数据");
    //捕捉数据输出 要怎么处理虽你便
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    [self imageFromSampleBuffer:sampleBuffer];
    /*Lock the buffer*/
    if(CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess)
    {
//        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddress(pixelBuffer);
//        size_t buffeSize = CVPixelBufferGetDataSize(pixelBuffer);
        
        if(self->firstFrame)
        {
            if(1)
            {
                //第一次数据要求：宽高，类型
//                int width = CVPixelBufferGetWidth(pixelBuffer);
//                int height = CVPixelBufferGetHeight(pixelBuffer);
                
                int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
                switch (pixelFormat) {
                    casekCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_nv12; // iPhone 3GS or 4
//                        NSLog(@"Capture pixel format=NV12");
                        NSLog(@"1111111111");

                        break;
                    casekCVPixelFormatType_422YpCbCr8:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_uyvy422; // iPhone 3
//                        NSLog(@"Capture pixel format=UYUY422");
                        NSLog(@"22222222222");

                        break;
                    default:
                        //TMEDIA_PRODUCER(producer)->video.chroma = tmedia_rgb32;
//                        NSLog(@"Capture pixel format=RGB32");
                        NSLog(@"33333333333");

                        break;
                }
                
                self->firstFrame = NO;
            }
        }
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        UIImageView * image = [[UIImageView alloc] init];
        
    }
}
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}
@end
