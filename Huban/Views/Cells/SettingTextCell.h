//
//  SettingTextCell.h
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_SettingTextCell @"SettingTextCell"

#import <UIKit/UIKit.h>

@interface SettingTextCell : UITableViewCell
@property (strong, nonatomic) NSString *textValue;
@property (copy, nonatomic) void (^textChangeBlock)(NSString *textValue);

- (void)setTextValue:(NSString *)textValue;
@end
