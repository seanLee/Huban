//
//  SettingMeViewController.h
//  Huban
//
//  Created by sean on 15/8/5.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface MeSettingViewController : BaseViewController
@property (copy, nonatomic) void (^refreshBlock)();
@end
