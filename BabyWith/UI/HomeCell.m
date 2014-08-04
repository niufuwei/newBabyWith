//
//  HomeCell.m
//  BabyWith
//
//  Created by laoniu on 14-6-26.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "HomeCell.h"
#import "Configuration.h"

@implementation HomeCell
@synthesize title;
@synthesize image;
@synthesize isShare;
@synthesize state;
@synthesize jiantou;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 35, 35)];
        [self.contentView addSubview:image];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.size.width+image.frame.origin.x+10, 0, 200, 30)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont systemFontOfSize:15];
        title.textColor = babywith_color(0x373737);
        [self.contentView addSubview:title];
        
        state = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.size.width+image.frame.origin.x+10, title.frame.size.height+title.frame.origin.y - 5, 120, 20)];
        state.backgroundColor = [UIColor clearColor];
        state.font = [UIFont systemFontOfSize:13];
        state.textColor = babywith_color(0x909090);
        state.textColor = [UIColor grayColor];
        [self.contentView addSubview:state];
        
        isShare= [[UILabel alloc] initWithFrame:CGRectMake(state.frame.size.width+state.frame.origin.x+10, title.frame.size.height+title.frame.origin.y, 120, 20)];
        isShare.backgroundColor = [UIColor clearColor];
        isShare.font = [UIFont systemFontOfSize:12];
        isShare.textColor =babywith_green_color;
        [self.contentView addSubview:isShare];
        
        jiantou = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-25,18.5, 10, 13)];
        [jiantou setImage:[UIImage imageNamed:@"qietu_40.png"]];
        [self addSubview:jiantou];

        self.backgroundColor = [UIColor clearColor];
        
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
