//
//  HeaderView.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-4-1.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 150, 20)];
        _headerLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_headerLabel];
        
        _AllSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _AllSelectButton.frame = CGRectMake(self.frame.size.width-55, 10, 45,20 );
        _AllSelectButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_AllSelectButton];
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
