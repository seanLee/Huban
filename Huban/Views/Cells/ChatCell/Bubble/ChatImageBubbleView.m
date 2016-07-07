//
//  ChatImageBubbleView.m
//  Huban
//
//  Created by sean on 15/9/17.
//  Copyright © 2015年 sean. All rights reserved.
//

#define KChatImageBubbleView_ImageWidth 150
#define kChatImageBubbleView_ImageHeight 140

#import "ChatImageBubbleView.h"

@interface ChatImageBubbleView ()

@end

@implementation ChatImageBubbleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KChatImageBubbleView_ImageWidth, kChatImageBubbleView_ImageHeight)];
        _contentImageView.layer.cornerRadius = 5.f;
        _contentImageView.layer.masksToBounds = YES;
        [self addSubview:_contentImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isSender) {
        [_contentImageView setX:0];
    } else {
        [_contentImageView setX:BUBBLE_ARROW_WIDTH];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(KChatImageBubbleView_ImageWidth + BUBBLE_ARROW_WIDTH, kChatImageBubbleView_ImageHeight);
}

#pragma mark - Public
+ (CGFloat)heightForBubbleWithObject:(EaseMessageModel *)message {
    return kChatImageBubbleView_ImageHeight;
}
@end
