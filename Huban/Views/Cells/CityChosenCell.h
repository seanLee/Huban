//
//  CityChosenCell.h
//  Huban
//
//  Created by sean on 15/8/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_CityChosenCell @"CityChosenCell"

#import <UIKit/UIKit.h>

@interface CityChosenCell : UITableViewCell
@property (strong, nonatomic) NSArray *dataItems;
@property (assign, nonatomic) BOOL showIndicator;
@property (copy, nonatomic) void (^groupTitleTapBlock)(BOOL);
@property (copy, nonatomic) void (^itemClickedBlock)(Region *region);

- (void)setGroupTitleStr:(NSString *)title;
- (void)checkState:(BOOL)state;

+ (CGFloat)cellHeightWithDataItms:(NSArray *)dataItems andDropList:(BOOL)showDropDown;
@end
