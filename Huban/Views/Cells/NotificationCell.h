//
//  NotificationCell.h
//  Huban
//
//  Created by sean on 15/9/21.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kCellIdentifier_NotificationCell @"NotificationCell"

#import <UIKit/UIKit.h>
#import "TopicComments.h"

@interface NotificationCell : UITableViewCell
@property (strong, nonatomic) TopicComment *curComment;

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
