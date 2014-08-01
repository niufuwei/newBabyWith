//
//  MessageCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-5-13.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 75)];
        _alertLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:15.0];
        _alertLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _alertLabel.numberOfLines = 0;
        [self addSubview:_alertLabel];
        
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 320, 20)];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_timeLabel];
        
        
        
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
