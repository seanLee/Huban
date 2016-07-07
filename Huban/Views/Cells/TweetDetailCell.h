//
//  TweetDetailCell.h
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIentifier_TweetDetailCell @"TweetDetailCell"
#define kCellIentifier_TweetDetailCell_Media @"TweetDetailCell_Media"

#import <UIKit/UIKit.h>

@interface TweetDetailCell : UITableViewCell
@property (copy, nonatomic) void (^headerClickedBlock)(User *);
@property (copy, nonatomic) void (^segmentedControlBlock)(NSInteger, Topic *);
@property (copy, nonatomic) void (^optionSelectedBlock)();

@property (strong, nonatomic) Topic *curTopic;

+ (CGFloat)heightWithMedias:(NSArray *)medias;
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
