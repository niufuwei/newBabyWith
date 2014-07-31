//
//  MessagViewController.h
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-19.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^block)(NSString*);

@interface MessagViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
{


    UITableView *_messageTableView;


}
@property (nonatomic,strong)block backName;
-(void)getBackName:(void(^)(NSString*))backName;

@end
