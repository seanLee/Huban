//
//  AroundUserCell.h
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_AroundUserCell @"AroundUserCell"

#import <UIKit/UIKit.h>

@interface AroundUserCell : UITableViewCell
@property (strong, nonatomic) User *curUser;

+ (CGFloat)cellHeight;
@end
