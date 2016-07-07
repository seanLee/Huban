//
//  CharacterCell.h
//  Huban
//
//  Created by sean on 15/8/5.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_CharacterCell @"CharacterCell"

#import <UIKit/UIKit.h>
#import "User.h"

@interface CharacterCell : UITableViewCell
@property (strong, nonatomic) User *curUser;

+ (CGFloat)cellHeight;
@end
