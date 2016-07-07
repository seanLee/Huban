//
//  TweetCommentsCell.h
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TweetCommentsCell @"TweetCommentsCell"

#import <UIKit/UIKit.h>
@class TopicComment;

@interface TweetCommentsCell : UITableViewCell
@property (strong, nonatomic) Topic *curTopic;
@property (copy, nonatomic) void (^commentButtonClicked)(TopicComment *feedbackComment);
@property (copy, nonatomic) void (^deleteCommentBlock)(TopicComment *comment);
@property (copy, nonatomic) void (^didTapLinkBlock)(NSDictionary *dict);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
