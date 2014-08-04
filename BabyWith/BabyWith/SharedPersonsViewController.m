//
//  SharedPersonsViewController.m
//  BabyWith
//
//  Created by eliuyan_mac on 14-4-23.
//  Copyright (c) 2014年 chaoyong.com. All rights reserved.
//

#import "SharedPersonsViewController.h"
#import "MainAppDelegate.h"
#import <AddressBook/AddressBook.h>


@implementation SharedPersonsViewController

- (id)initWithDeviceID:(NSString *)deviceID
{
    self = [super init];
    if (self) {
        self.deviceID = deviceID;
    }
        return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self titleSet:@"分享人员"];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    // Do any additional setup after loading the view.
    _sharedPersonTableView =  [[UITableView alloc] init];
    _sharedPersonTableView.delegate = self;
    _sharedPersonTableView.dataSource = self;
    _sharedPersonTableView.backgroundColor = [UIColor clearColor];
    _sharedPersonTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _sharedPersonTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _label = [[UILabel alloc] init];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isScreen" ] isEqualToString:@"yes"])
    {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:YES];
    [_sharedPersonTableView reloadData];
    
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[appDelegate.appDefault arrayForKey:[NSString stringWithFormat:@"%@_number",self.deviceID]]];
    NSLog(@"arr is %d",[arr count]);
    
    
    if ([arr count] == 0)
    {
        
        _sharedPersonTableView.frame = CGRectMake(0, 0, 0, 0);
        _label.frame = CGRectMake(20, 200, 280, 60);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text =@"您还没有将设备分享给别人";
        _label.hidden = NO;
        _label.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_label];
       
    }
    else
    {
        _label.hidden = YES;
        _sharedPersonTableView.frame = CGRectMake(0, 0, 320, 60.0*[self tableView:_sharedPersonTableView numberOfRowsInSection:0]);
        if (60.0*[self tableView:_sharedPersonTableView numberOfRowsInSection:0] > self.view.frame.size.height - 64)
        {
            _sharedPersonTableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height );
        }
        
        
    }
    [self.view addSubview:_sharedPersonTableView];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [[appDelegate.appDefault arrayForKey:[NSString stringWithFormat:@"%@_number",self.deviceID]] count];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 45;


}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *identifier  = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = babywith_color(0x373737);
         cell.backgroundColor = [UIColor whiteColor];
        
        
    }
    else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    
   
    NSString *phone = [[appDelegate.appDefault arrayForKey:[NSString stringWithFormat:@"%@_number",self.deviceID]] objectAtIndex:indexPath.row];
    
    if ([self getNameBytel:phone])
    {
        cell.textLabel.text = [self getNameBytel:phone];
        CGSize size = CGSizeMake(320, 45);
        CGSize labelsize = [[self getNameBytel:phone] sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        [cell.textLabel setFrame:CGRectMake(0, 0, labelsize.width, labelsize.height)];
        NSLog(@"cell.width is %f",cell.textLabel.frame.size.width);
    }
    else
    {
    
        cell.textLabel.text = phone;
        CGSize size = CGSizeMake(320, 45);
        CGSize labelsize = [phone sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        [cell.textLabel setFrame:CGRectMake(0, 0, labelsize.width, labelsize.height)];
        NSLog(@"cell.width 1 is %f",cell.textLabel.frame.size.width);

    
    }
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(320-25,16, 10, 13)];
    [accessoryView setImage:[UIImage imageNamed:@"qietu_40.png"]];
    [cell addSubview:accessoryView];
    
    
    UIImageView *statusImage = [[UIImageView alloc] initWithFrame:CGRectMake(cell.textLabel.frame.size.width + 20, 17.5 , 10, 10)];
    statusImage.image = [UIImage imageNamed:@"分享人员 (2)"];
    [cell addSubview:statusImage];
    
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 30, 45)];
    statusLabel.backgroundColor = [UIColor clearColor];
    
    statusLabel.text  = @"关闭";
    statusLabel.textColor = babywith_color(0xff5b7e);
    statusLabel.font = [UIFont systemFontOfSize:14.0];
    [cell addSubview:statusLabel];
    
    
    
    return cell;
}

-(NSString *)getNameBytel:(NSString *)telstr
{
    NSMutableArray* personArray = [[NSMutableArray alloc] init];
    //打开电话本数据库
    CFErrorRef error = NULL;
    ABAddressBookRef addressRef= ABAddressBookCreateWithOptions(NULL, &error);
    NSString *firstName, *lastName, *fullName;
    //返回所有联系人到一个数组中
    personArray = (__bridge_transfer NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressRef);
    
  
    NSUInteger peopleCounter = 0;
    for (peopleCounter = 0; peopleCounter < [personArray count]; peopleCounter++)
    {
         ABRecordRef person = (__bridge ABRecordRef)[personArray objectAtIndex:peopleCounter];
        firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);;
        lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (lastName !=nil)
        {
            fullName = [lastName stringByAppendingFormat:@"%@",firstName];
            
        }
        else
        {
            fullName = firstName;
        }
        NSLog(@"===%@",fullName);
        ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(person, kABPersonPhoneProperty);
        for(int i = 0 ;i < ABMultiValueGetCount(phones); i++)
        {
            NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, i);
            phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"===%@",phone); 
            if ([phone isEqualToString:telstr]) 
            {
                return fullName;
            }
        } 
    }
    return nil;
}
@end
