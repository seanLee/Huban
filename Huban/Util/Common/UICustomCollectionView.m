//
//  UICustomCollectionView.m
//  Huban
//
//  Created by sean on 15/9/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UICustomCollectionView.h"

@interface UICustomCollectionView ()

@end

@implementation UICustomCollectionView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *__tempView = [super hitTest:point withEvent:event];
    if (__tempView == self) {
        return nil;
    }
    return __tempView;
}
@end
