//
//  VedioQualityTableViewCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-7-31.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "VedioQualityTableViewCell.h"

@implementation VedioQualityTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _qualityImage = [[UIImageView alloc] initWithFrame:CGRectMake(280, 10, 20, 20)];
        [self addSubview:_qualityImage];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
