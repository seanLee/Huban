//
//  UISearchBar+Common.m
//  Huban
//
//  Created by sean on 15/10/14.
//  Copyright © 2015年 sean. All rights reserved.
//

#define CustomerBGTag 999

#import "UISearchBar+Common.h"

@implementation UISearchBar (Common)
- (void)insertBGColor:(UIColor *)backgroundColor {
    UIView *realView = [[self subviews] firstObject];
    [[realView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == CustomerBGTag) {
            [obj removeFromSuperview];
        }
    }];
    if (backgroundColor) {
        UIImageView *customBg = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:backgroundColor withFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + 20)]];
        [customBg setY:-20];
        customBg.tag = CustomerBGTag;
        [[[self subviews] firstObject] insertSubview:customBg atIndex:1];
    }
}
@end
