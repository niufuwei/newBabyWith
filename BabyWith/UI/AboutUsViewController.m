//
//  AboutUsViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-3-18.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self titleSet:@"关于我们"];
    
    self.view.backgroundColor = babywith_color(0xf5f5f5);
    
    if (IOS7) {
        self.rightLab.frame=CGRectMake(80, 400-44, 160, 30);
        self.detailLab.frame=CGRectMake(20, 430-44, 280, 20);
    }
    else
    {
        self.rightLab.frame=CGRectMake(80, 380-64, 160, 30);
        self.detailLab.frame=CGRectMake(20, 410-64, 280, 20);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


@end
