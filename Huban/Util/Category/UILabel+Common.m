//
//  UILabel+Common.m
//  Huban
//
//  Created by sean on 15/8/12.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UILabel+Common.h"

@implementation UILabel (Common)
- (void)fitToText:(NSString *)textStr {
    self.text = textStr;
    [self sizeToFit];
}
@end
