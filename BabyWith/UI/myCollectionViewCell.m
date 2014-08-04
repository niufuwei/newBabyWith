//
//  myCollectionViewCell.m
//  BabyWith
//
//  Created by laoniu on 14-5-13.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "myCollectionViewCell.h"

@implementation myCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _image = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75.5, 75.5)] autorelease];
        [self addSubview:_image];
        
        _videoImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"播放视频 (4).png"]] autorelease];
        _videoImage.frame = CGRectMake(21.75, 21.75,32, 32);
        [self addSubview:_videoImage];
        
        _deleteImage = [[[UIImageView alloc] initWithFrame:CGRectMake(50, 5, 20, 20)] autorelease];
        [_deleteImage.layer setCornerRadius:10];
        [self addSubview:_deleteImage];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
