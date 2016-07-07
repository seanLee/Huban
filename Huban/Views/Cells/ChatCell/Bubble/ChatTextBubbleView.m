//
//  ChatTextBubbleView.m
//  Huban
//
//  Created by sean on 15/9/15.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define TEXTLABEL_MAX_WIDTH 200 // textLaebl 最大宽度
#define TEXTLABEL_FONF [UIFont systemFontOfSize:14.f]

#import "ChatTextBubbleView.h"
#import "UITTTAttributedLabel.h"

@interface ChatTextBubbleView ()
@end

@implementation ChatTextBubbleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
            _contentLabel.numberOfLines = 0;
            _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.font = TEXTLABEL_FONF;
            _contentLabel.textColor = SYSFONTCOLOR_BLACK;
            _contentLabel.userInteractionEnabled = NO;
            [_bgView addSubview:_contentLabel];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.isSender) {
        frame.origin.x = BUBBLE_VIEW_PADDING;
    } else {
        frame.origin.x = BUBBLE_ARROW_WIDTH + BUBBLE_VIEW_PADDING;
    }
    frame.origin.y = BUBBLE_VIEW_PADDING;
    [_contentLabel setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
    CGSize reSize = [self.messageText getSizeWithFont:TEXTLABEL_FONF constrainedToSize:textBlockMinSize];
    CGFloat textHeight = reSize.height;
    textHeight = MAX(reSize.height + BUBBLE_VIEW_PADDING*2, 40.f);
    //会有一个单位的偏差,不知道原因
    reSize.width += 1;
    
    return CGSizeMake(reSize.width + BUBBLE_VIEW_PADDING*2 + BUBBLE_ARROW_WIDTH, textHeight);
}

#pragma mark - Publick
+ (CGFloat)heightForBubbleWithObject:(EaseMessageModel *)message {
    CGFloat viewHeight = 0;
    EMTextMessageBody *textBody = (EMTextMessageBody *)message.firstMessageBody;
    
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
    CGSize reSize = [textBody.text getSizeWithFont:TEXTLABEL_FONF constrainedToSize:textBlockMinSize];
    
    viewHeight = MAX(reSize.height + 2*BUBBLE_VIEW_PADDING, 40.f);
    return viewHeight;
}

@end
