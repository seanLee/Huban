//
//  ChatBaseBubbleView.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ChatBaseBubbleView.h"

@interface ChatBaseBubbleView ()
@end

@implementation ChatBaseBubbleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIGestureImageView alloc] initWithFrame:self.bounds];
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Public
+ (CGFloat)heightForBubbleWithObject:(id)message {
    return 40.f;
}
@end
