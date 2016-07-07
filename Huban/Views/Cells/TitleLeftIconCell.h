//
//  UserInfoIconCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_TitleLeftIconCell @"TitleLeftIconCell"

#import <UIKit/UIKit.h>

@interface TitleLeftIconCell : UITableViewCell
@property (assign, nonatomic) BOOL showIndicator;
@property (assign, nonatomic) BOOL hasNewIndicator;

- (void)setTitle:(NSString *)title icon:(NSString *)iconName;
- (void)setDetailStr:(NSString *)detailText;

+ (CGFloat)cellHeight;
@end
    