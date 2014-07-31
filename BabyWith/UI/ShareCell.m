//
//  ShareCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-6-26.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "ShareCell.h"

@implementation ShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _imageCell =[[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 25, 30)];
        [self addSubview:_imageCell];
        
         _nameLabel =[[UILabel alloc] initWithFrame:CGRectMake(50, 10, 180, 40)];
        _nameLabel.font = [UIFont systemFontOfSize:20];
        [self addSubview:_nameLabel];
        
        
        _bindTimeLabel =[[UILabel alloc] initWithFrame:CGRectMake(50, 55, 180, 18)];
        _bindTimeLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_bindTimeLabel];
        
        
        _chooseImage =[[UIImageView alloc] initWithFrame:CGRectMake(280, 25, 30, 30)];
        [self addSubview:_chooseImage];
        
        
        
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
