//
//  UIBadgeView.h
//  Huban
//
//  Created by sean on 15/7/24.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBadgeView : UIView
@property (copy, nonatomic) NSString *badgeValue;

+ (UIBadgeView *)viewWithBadgeTip:(NSString *)badgeValue;

+ (CGSize)badgeSizeWithStr:(NSString *)badgeValue font:(UIFont *)font;
- (CGSize)badgeSizeWithStr:(NSString *)badgeValue;
@end
