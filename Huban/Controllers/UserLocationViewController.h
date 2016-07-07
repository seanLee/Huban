//
//  UserLocationViewController.h
//  Huban
//
//  Created by sean on 15/12/1.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface UserLocationViewController : BaseViewController
@property (copy, nonatomic) void (^didClickedSendButtonBlock)(BMKReverseGeoCodeResult *result);

@end
