//
//  WifiTableViewCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-7-31.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "WifiTableViewCell.h"

@implementation WifiTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _unlockLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 15, 40, 30)];
        _lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(290, 20, 20, 20)];
        [self addSubview:_unlockLabel];
        [self addSubview:_lockImage];
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
