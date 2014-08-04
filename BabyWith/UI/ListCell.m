//
//  ListCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //状态
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 140, 30)];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.font = [UIFont systemFontOfSize:16.0];
        [self addSubview:_statusLabel];
        //名字
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 150, 30)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_nameLabel];
        //logo
        _logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
        [self addSubview:_logoImage];
        
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
