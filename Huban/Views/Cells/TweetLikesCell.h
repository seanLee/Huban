//
//  TweetLikesCell.h
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIentifier_TweetLikesCell @"TweetLikesCell"

#import <UIKit/UIKit.h>
@class TopicLike;

@interface TweetLikesCell : UITableViewCell
@property (strong, nonatomic) Topic *curTopic;
@property (copy, nonatomic) void (^likeButtonClicked)();
@property (copy, nonatomic) void (^userClickedBlock)(TopicLike *curUser);
@property (copy, nonatomic) void (^showMoreLikerBlock)(Topic *curTopic);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
