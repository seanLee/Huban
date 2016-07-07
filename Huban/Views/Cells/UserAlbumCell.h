//
//  UserAlbumCell.h
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_UserAlbumCell  @"UserAlbumCell"

#import <UIKit/UIKit.h>

@interface UserAlbumCell : UITableViewCell
@property (strong, nonatomic) NSArray *dataItems;

- (void)setTitleStr:(NSString *)title;

+ (CGFloat)cellHeight;
@end
