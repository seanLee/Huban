//
//  SendLocationViewController.h
//  Huban
//
//  Created by sean on 15/12/2.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"
@class BMKPoiInfo;

@interface SendLocationViewController : BaseViewController
@property (copy, nonatomic) void (^didClickedSendButtonBlock)(double longtitude,double latitude,NSString *address);
@end
