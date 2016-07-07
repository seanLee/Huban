//
//  CircleDetailViewController.h
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface CircleDetailViewController : BaseViewController
@property (copy, nonatomic) void (^headerClickedBlock)(User *);

@property (strong, nonatomic) Topic *curTopic;
@end
