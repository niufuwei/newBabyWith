//
//  PhotoScanViewController.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-4-3.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"
#import "APICommon.h"

@interface PhotoScanViewController : BaseViewController<UIScrollViewDelegate,UIAlertViewDelegate>{
    
    int pageCount;
    UIScrollView *_photoScrollView;
    NSMutableArray *_photoArray;
    int _currentPage;
    int _type;
    NSObject *_delegate;
    
    UIImageView *_playView;    //播放的imageView
    int _count;                //照片的张数
    NSData *_vedioData;       //取出来的数据
    UIImage *_image;          //取出来的每一张照片
    
    BOOL _isBack;
    FILE * FileHandle;
    UIView *aView;
}

- (id)initWithArray:(NSArray *)array Type:(int) type CurrentPage:(int )currentPage Delegate:(NSObject *)delegate;

@end