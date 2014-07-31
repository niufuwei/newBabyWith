//
//  CameraPhotoRecordViewController.h
//  AiJiaJia
//
//  Created by wangminhong on 13-6-21.
//  Copyright (c) 2013年 shancheng.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "APICommon.h"


@interface CameraPhotoRecordViewController : BaseViewController<UIScrollViewDelegate,UIAlertViewDelegate>{
    
    int pageCount;
    UIScrollView *_photoScrollView;
    NSMutableArray *_photoArray;
    int _currentPage;
    int _type;
    NSObject *_delegate;
    
    UIImageView *_playView;
    int _playTime;
    
    int _count;
    NSData *_vedioData;
    UIImage *_image;
    
    BOOL _isBack;
    FILE * FileHandle;
    UIView *aView;
}

- (id)initWithArray:(NSArray *)array Type:(int) type CurrentPage:(int )currentPage Delegate:(NSObject *)delegate;

@end
