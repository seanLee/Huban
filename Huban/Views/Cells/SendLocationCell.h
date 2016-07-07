//
//  SendLocationCell.h
//  Huban
//
//  Created by sean on 15/12/4.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kCellIdentifier_SendLocationCell @"SendLocationCell"

#import <UIKit/UIKit.h>

@interface SendLocationCell : UITableViewCell
- (void)setName:(NSString *)nameStr;
- (void)setAddress:(NSString *)addressStr;

+ (CGFloat)cellHeight;
@end
