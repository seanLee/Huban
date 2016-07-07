//
//  UITTTAttributedLabel.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TTTAttributedLabel.h"

typedef void(^UITTTLabelTapBlock)(id aObj);

@interface UITTTAttributedLabel : TTTAttributedLabel
- (void)addLongPressForCopy;
- (void)addLongPressForCopyWithBGColor:(UIColor *)color andNormalColor:(UIColor *)normalColor;
- (void)addTapBlock:(UITTTLabelTapBlock)block;
- (void)addDeleteBlock:(UITTTLabelTapBlock)block;
@end
