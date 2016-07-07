//
//  UITapImageView.m
//  Huban
//
//  Created by sean on 15/7/24.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UITapImageView.h"

@interface UITapImageView () <UIGestureRecognizerDelegate>
@property (copy, nonatomic) void(^tapBlock)(id);
@end

@implementation UITapImageView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)tap {
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"%@",event.allTouches);
//    return nil;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"%@",touch);
//    return YES;
//}

- (void)addTapBlock:(void (^)(id))tapAction {
    self.tapBlock = tapAction;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
}

- (void)setImageWithURL:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void (^)(id))tapAction {
    [self sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
    [self addTapBlock:tapAction];
}

@end
