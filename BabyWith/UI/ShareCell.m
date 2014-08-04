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
        
//        _imageCell =[[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 25, 30)];
//        [self addSubview:_imageCell];
        
         _nameLabel =[[UILabel alloc] initWithFrame:CGRectMake(60, 3, 180, 40)];
        _nameLabel.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:_nameLabel];
        
        
        _bindTimeLabel =[[UILabel alloc] initWithFrame:CGRectMake(60, 33, 180, 20)];
        _bindTimeLabel.font = [UIFont systemFontOfSize:15.0];
        _bindTimeLabel.textColor = [UIColor grayColor];
        [self addSubview:_bindTimeLabel];
        
        
        _chooseImage =[[UIImageView alloc] initWithFrame:CGRectMake(10, 30-25/2, 25, 25)];
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
