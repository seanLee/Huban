//
//  CityChosenViewController.h
//  Huban
//
//  Created by sean on 15/8/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger,RegionType) {
    RegionType_PersionalInfo = 0,
    RegionType_CityCircle
};

#import "BaseViewController.h"

@interface CityChosenViewController : BaseViewController
@property (copy, nonatomic) void (^selectedRegionBlock)(Region *region);
@property (assign, nonatomic) RegionType type;
@end
