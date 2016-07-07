//
//  ContactBookCell.h
//  Huban
//
//  Created by sean on 15/8/16.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_ToUserCell @"ToUserCell"

#import <UIKit/UIKit.h>

@interface ToUserCell : UITableViewCell
@property (strong, nonatomic) Contact *contact;

+ (CGFloat)cellHeight;
@end
