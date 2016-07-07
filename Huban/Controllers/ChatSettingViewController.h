//
//  ChatSettingViewController.h
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface ChatSettingViewController : BaseViewController
@property (strong, nonatomic) Contact *curConact;

@property (copy, nonatomic) void (^popToChatVCBlock)();
@property (copy, nonatomic) void (^clearRecordBlock)();
@end
