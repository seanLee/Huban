//
//  TweetLocationViewController.h
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface TweetLocationViewController : BaseViewController
@property (copy, nonatomic) void (^selectedLocationBlock)(NSString *location);
@end
