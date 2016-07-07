//
//  TweetLikeUserCell.h
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TweetLikeUserCell @"TweetLikeUserCell"

#import <UIKit/UIKit.h>
#import "User.h"
@class TopicLike;

@interface TweetLikeUserCell : UICollectionViewCell
- (void)configWithUser:(TopicLike *)user likesNum:(NSNumber *)likes;
@end
