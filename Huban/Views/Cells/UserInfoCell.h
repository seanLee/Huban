//
//  UserInfoCell.h
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, UserInfoType) {
    UserInfoTypeNormal = 0,
    UserInfoTypeAround
};

#define kCellIdentifier_UserInfoCell @"UserInfoCell"

#import <UIKit/UIKit.h>

@interface UserInfoCell : UITableViewCell
@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) Contact *curContact;
@property (assign, nonatomic) UserInfoType infoType;

+ (CGFloat)cellHeight;
@end
