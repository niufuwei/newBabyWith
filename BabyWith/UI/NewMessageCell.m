//
//  NewMessageCell.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-4-22.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "NewMessageCell.h"
#import "Configuration.h"
@implementation NewMessageCell

- (void)awakeFromNib
{
    // Initialization code
    
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont systemFontOfSize:15.0];
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    //20.79.104.30
    _agreeShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(22, 50, 133, 30)];
    [_agreeShareBtn setImage:[UIImage imageNamed:@"qietu_120.png"] forState:UIControlStateNormal];
    [self addSubview:_agreeShareBtn];
    
    
    self.backgroundColor = [UIColor clearColor];
    
    //196.79.104.30
    _refuseShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(165, 50, 133, 30)];
    [_refuseShareBtn setImage:[UIImage imageNamed:@"qietu_147.png"] forState:UIControlStateNormal];
    [self addSubview:_refuseShareBtn];
    
    
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}


@end
