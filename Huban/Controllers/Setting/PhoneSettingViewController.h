//
//  PhoneSettingViewController.h
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface PhoneSettingViewController : BaseViewController
@property (copy, nonatomic) void (^changeMobileBlock)();
@end
