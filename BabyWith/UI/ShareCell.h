//
//  ShareCell.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-6-26.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCell : UITableViewCell
{

    UIImageView * _imageCell;
    UILabel *_nameLabel;
    UILabel *_bindTimeLabel;
    UIImageView *_chooseImage;

}
//@property (nonatomic,strong) UIImageView * imageCell;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *bindTimeLabel;
@property (nonatomic,strong) UIImageView *chooseImage;
@end
