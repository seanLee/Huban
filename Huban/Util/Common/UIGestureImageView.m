//
//  UILongPressMenuImageView.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UIGestureImageView.h"
#import <objc/runtime.h>

@interface UIGestureImageView ()
@property (strong, nonatomic) NSArray *longPressTitle;
@property (copy, nonatomic) void (^longPressMenuBlock)(NSInteger index, NSString *title);
@property (copy, nonatomic) void (^doubleTapBlock)();
@property (copy, nonatomic) void (^singleTapBlock)();
@end

@implementation UIGestureImageView
- (BOOL)canBecomeFirstResponder {
    if (self.longPressMenuBlock) {
        return YES;
    } else {
        return [super canBecomeFirstResponder];
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.longPressMenuBlock) {
        for (int i = 0; i < self.longPressTitle.count; i++) {
            if (action == NSSelectorFromString([NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i])) {
                return YES;
            }
        }
        return NO;
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void (^)(NSInteger, NSString *))block {
    self.longPressMenuBlock = block;
    self.longPressTitle = titles;
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

- (void)addSingleTapWithBlock:(void (^)())block {
    self.singleTapBlock = block;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap];
}

- (void)addDoubleTapWithBlock:(void (^)())block {
    self.doubleTapBlock = block;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDouleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:self.longPressTitle.count];
        Class cls = [self class];
        SEL imp = @selector(longPressMenuClicked:);
        for (int i = 0; i < self.longPressTitle.count; i++) {
            NSString *title = [self.longPressTitle objectAtIndex:i];
            //注册名添加方法Sel
            SEL sel = sel_registerName([[NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i] UTF8String]);
            class_addMethod(cls, sel, [cls instanceMethodForSelector:imp], "v@");
            UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:sel];
            [menuItems addObject:menuItem];
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)longPressMenuClicked:(id)sender {
    NSString *selStr = NSStringFromSelector(_cmd);
    NSString *preFix = @"easeLongPressMenuClicked_";
    NSString *indexStr = [selStr substringFromIndex:preFix.length];
    NSInteger index = indexStr.integerValue;
    if (indexStr >=0 && index < self.longPressTitle.count) {
        NSString *title = [self.longPressTitle objectAtIndex:index];
        if (self.longPressMenuBlock) {
            self.longPressMenuBlock(index,title);
        }
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

- (void)handleDouleTap:(UIGestureRecognizer *)recognizer {
    if (self.doubleTapBlock) {
        self.doubleTapBlock();
    }
}
@end
