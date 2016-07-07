//
//  TitleAndSwitchCell.h
//  Huban
//
//  Created by sean on 15/7/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TitleAndSwitchCell @"TitleAndSwitchCell"

#import <UIKit/UIKit.h>

@interface TitleAndSwitchCell : UITableViewCell
@property (assign, nonatomic) BOOL switchSelected;
@property (assign, nonatomic) BOOL canSwitch;
@property (copy, nonatomic) void (^haveSwitchSettingBlock)(BOOL selected);

- (void)setTitleStr:(NSString *)title;

+ (CGFloat)cellHeight;
@end
