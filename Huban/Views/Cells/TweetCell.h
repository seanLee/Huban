//
//  TweetCell.h
//  Huban
//
//  Created by sean on 15/8/1.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, TopicType) {
    TopicTypeNormal = 0,
    TopicTypeCollection
};

typedef NS_ENUM(NSInteger, ActionType) {
    ActionType_Delete = 0,
    ActionType_Shield
};

#define kCellIentifier_TweetCell @"TweetCell"
#define kCellIentifier_TweetCell_Media @"TweetCell_Media"

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell
@property (strong, nonatomic) Topic *curTopic;
@property (assign, nonatomic) TopicType topicType;
@property (assign, nonatomic) ActionType actionType;

@property (copy, nonatomic) void (^userInfoBlock)(NSString *userCode);
@property (copy, nonatomic) void (^segmentedControlBlock)(NSInteger, Topic *);
@property (copy, nonatomic) void (^showMoreDetailBlock)(BOOL state);
@property (copy, nonatomic) void (^actionButtonClickedBlock)(ActionType type);
@property (copy, nonatomic) void (^transpondBlock)(UIImage *transpondImage);

- (void)resetState:(BOOL)state;

+ (CGFloat)heightWithMedias:(NSArray *)medias;

+ (CGFloat)cellHeightWithObj:(id)obj andTweetType:(TopicType)type canShowFullContent:(BOOL)showFullContent;
@end
