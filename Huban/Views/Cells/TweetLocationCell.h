//
//  TweetLocationCell.h
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TweetLocationCell @"TweetLocationCell"

#import <UIKit/UIKit.h>

@interface TweetLocationCell : UITableViewCell
@property (assign, nonatomic) BOOL showCheckmark;
@property (copy, nonatomic) void (^locationSelectedBlock)(NSString *);

- (void)setTextStr:(NSString *)textStr;

+ (CGFloat)cellHeight;
@end
