//
//  TweetPrivacyViewController.h
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetType_CityCircle @"CityCircle"
#define kTweetType_FriendCircle @"FriendCircle"
#define kTweetType_Album @"Album"

typedef NS_ENUM(NSInteger, TweetPrivacyTyep) {
    TweetPrivacyTyepOpen = 0,
    TweetPrivacyTyepOnlyFriend,
    TweetPrivacyTyepOnlyStranger,
    TweetPrivacyTyepPrivate
};

#import "BaseViewController.h"
#import "SendTweetViewController.h"

@interface TweetPrivacyViewController : BaseViewController
@property (assign, nonatomic) TweetPrivacyTyep privacyType;
@property (assign, nonatomic) SendTopicType topicType;
@property (copy, nonatomic) void (^didSelectedPrivacyType)(TweetPrivacyTyep type);
@end

#define kCellIdentifer_TweetPrivacyCell @"TweetPrivacyCell"

@interface TweetPrivacyCell : UITableViewCell
@property (assign, nonatomic) TweetPrivacyTyep privacyType;
@property (assign, nonatomic) BOOL showCheckmark;

- (void)setTitleStr:(NSString *)titleStr andDetailStr:(NSString *)detailStr;

+ (CGFloat)cellHeight;
@end
