//
//  SettingViewController.h
//  Huban
//
//  Created by sean on 15/7/30.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingViewController : BaseViewController
@property (copy, nonatomic) void (^refreshBlock)();
@end
