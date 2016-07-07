//
//  TitleLeftImageCell.h
//  Huban
//
//  Created by sean on 15/8/13.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TitleLeftImageCell @"TitleLeftImageCell"

#import <UIKit/UIKit.h>

@interface TitleLeftImageCell : UITableViewCell
- (void)setTitle:(NSString *)title bigIcon:(NSString *)iconName;
+ (CGFloat)cellHeight;
@end
