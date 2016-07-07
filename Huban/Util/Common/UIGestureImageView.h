//
//  UILongPressMenuImageView.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureImageView : UIImageView
- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block;
- (void)addSingleTapWithBlock:(void(^)())block;
- (void)addDoubleTapWithBlock:(void(^)())block;
@end
