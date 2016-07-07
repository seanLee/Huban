//
//  UserGroupCell.h
//  Huban
//
//  Created by sean on 15/8/18.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_UserGroupCell @"UserGroupCell"

#import <UIKit/UIKit.h>

@interface UserGroupCell : UITableViewCell
@property (strong, nonatomic) NSArray *dataItems;
@property (copy, nonatomic) void (^groupTitleTapBlock)(BOOL);

- (void)setGroupTitleStr:(NSString *)title;

+ (CGFloat)cellHeightWithDataItms:(NSArray *)dataItems andDropList:(BOOL)showDropDown;
@end
