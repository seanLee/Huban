//
//  SettingTextViewController.h
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingTextViewController : BaseViewController
@property (strong, nonatomic) NSString *textValue;
@property (copy, nonatomic) void (^doneBlock)(NSString *);

@property (assign, nonatomic) BOOL canSubmibNil;
@property (assign, nonatomic) BOOL limited;
@property (assign, nonatomic) NSInteger limitedCount;
@end
