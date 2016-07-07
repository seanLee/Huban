//
//  TweetImagesPickCell.h
//  Huban
//
//  Created by sean on 15/9/1.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TweetImagesPickCell @"TweetImagesPickCell"

#import <UIKit/UIKit.h>

@interface TweetImagesPickCell : UITableViewCell
@property (strong, nonatomic) Topic *curTopic;
@property (copy, nonatomic) void (^addPhotoBlock)();
@property (copy, nonatomic) void (^photoSelectedBlock)(NSInteger,NSMutableDictionary *);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
