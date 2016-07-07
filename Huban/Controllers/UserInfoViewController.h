//
//  UserInfoViewController.h
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"
#import "UserInfoCell.h"

@interface UserInfoViewController : BaseViewController
@property (strong, nonatomic) NSString *userCode;
@property (assign, nonatomic) UserInfoType infoType;
@property (assign, nonatomic) BOOL fromChatVC;
@property (assign, nonatomic) BOOL fromSearchVC;
@property (copy, nonatomic) void (^popToChatVCBlock)();
@end
