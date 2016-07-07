//
//  UserInfoIconCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_InfoIconCell @"UserInfoIconCell"

#import <UIKit/UIKit.h>

@interface InfoIconCell : UITableViewCell
- (void)setTitle:(NSString *)title icon:(NSString *)iconName;
+ (CGFloat)cellHeight;
@end
    