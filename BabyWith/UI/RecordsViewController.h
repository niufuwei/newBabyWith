//
//  RecordsViewController.h
//  BabyAgent
//
//  Created by Fly on 14-3-12.
//  Copyright (c) 2014年 lifei. All rights reserved.
//

#import "BaseViewController.h"
#import "ImagePickerController.h"
@interface RecordsViewController : BaseViewController<ImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,NavgationDelegate>
{

    ImagePickerController *_picker;
    NSMutableArray *_yearArray;
    
    UICollectionView *_imageCollection;
    
    NSMutableDictionary *_sectionNumberDictionary;
    NSMutableDictionary *_recordLocalMonthListDic;
    NSMutableDictionary *_recordLocalMonthCountDic;
    NSMutableDictionary *_recordLocalDayListDic;
    NSMutableDictionary *_deleteDic;
    
    int _year;
    int localLoadFlag;

    NSDateFormatter *_dateFormatter;
    
    NSMutableArray *_countForSectionArray;
    NSMutableArray *_sectionArray;
    
    UIImageView *_startImage;
    
    UILabel *_label;
    BOOL isFirst;

    NSMutableDictionary * RowDictionary;
    NSMutableDictionary * statusDictionary;
    NSMutableArray * deleteArray;
    NSMutableDictionary * arrayDictionary;
    UIButton * selectButton;
    BOOL isDelete;
    BOOL isAllSelect;
}
@property (nonatomic,copy) UICollectionView *imageCollection;
//-(void)DeleteRecord:(NSDictionary *)dic;
//-(void)InsertRecord:(NSDictionary *)dic;
@end
