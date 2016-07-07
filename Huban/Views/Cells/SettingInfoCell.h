//
//  SettingInfoCell.h
//  Huban
//
//  Created by sean on 15/9/23.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kCellIdentifier_SettingInfoCell @"SettingInfoCell"

#import <UIKit/UIKit.h>

@interface SettingInfoCell : UITableViewCell
@property (strong, nonatomic) User *curUser;

+ (CGFloat)cellHeight;
@end
