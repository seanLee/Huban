//
//  CircleDetailViewController.h
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface TweetDetailViewController : BaseViewController
@property (copy, nonatomic) void (^headerClickedBlock)(User *);
@property (copy, nonatomic) void (^commentedBlock)();
@property (copy, nonatomic) void (^blockTopicBlock)();
@property (assign, nonatomic) BOOL tweetFromCityCircle;

@property (strong, nonatomic) Topic *curTopic;
@end
