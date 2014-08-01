//
//  WifiTableViewCell.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-7-31.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WifiTableViewCell : UITableViewCell
{

    UILabel *_unlockLabel;
    UIImageView *_lockImage;

}
@property (nonatomic,strong) UILabel *unlockLabel;
@property (nonatomic,strong) UIImageView *lockImage;
@end
