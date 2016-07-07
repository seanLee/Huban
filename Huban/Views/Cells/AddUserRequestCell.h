//
//  AddCustomerRequestCell.h
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_AddCustomerRequestCell @"AddCustomerRequestCell"

typedef NS_ENUM(NSInteger, AddedUserState) {
    AddedUserStateNewAdded = 0,
    AddedUserStateRequest,
    AddedUserStateHasAdded
};

#import <UIKit/UIKit.h>

@interface AddUserRequestCell : UITableViewCell
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) AddedUserState state;

@property (copy, nonatomic) void (^actionClicked)(User *curUser);

+ (CGFloat)cellHeight;
@end
