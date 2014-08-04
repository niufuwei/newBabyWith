//
//  ImageShowController.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-6-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"

@interface ImageShowController : BaseViewController<UIScrollViewDelegate,UIAlertViewDelegate>
{
    
    int pageCount;
    UIScrollView *_photoScrollView;
    NSMutableArray *_photoArray;
    int _currentPage;
    
    int _count;                //照片的张数
    UIImage *_image;          //取出来的每一张照片
    
}
- (id)initWithArray:(NSArray *)array ;

@end
