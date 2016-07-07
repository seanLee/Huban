//
//  ApplicationAuthViewController.h
//  Huban
//
//  Created by sean on 15/12/7.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface ApplicationAuthViewController : BaseViewController
@property (copy, nonatomic) void (^addedFriendBlock)(NSString *confirmMemo);
@end
