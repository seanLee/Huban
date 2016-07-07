//
//  TranspondCell.h
//  Huban
//
//  Created by sean on 15/12/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TranspondCell @"TranspondCell"

#import <UIKit/UIKit.h>

@interface TranspondCell : UITableViewCell
@property (strong, nonatomic) Contact *curContact;
@property (assign, nonatomic) BOOL checked;
+ (CGFloat)cellHeight;
@end
