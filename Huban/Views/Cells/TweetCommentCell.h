//
//  TweetCommentCell.h
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TweetCommentCell @"TweetCommentCell"

#import <UIKit/UIKit.h>
#import "TopicComment.h"

@interface TweetCommentCell : UITableViewCell
@property (strong, nonatomic) TopicComment *curComment;
@property (copy, nonatomic) void (^didTapLinkBlock)(NSDictionary *dict);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
