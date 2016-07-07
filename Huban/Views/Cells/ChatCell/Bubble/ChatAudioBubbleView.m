//
//  ChatAudioBubbleView.m
//  Huban
//
//  Created by sean on 15/9/16.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define VOICEBUBBLE_MAX_WIDTH 200   // 语音 最大宽度
#define VOICEBUBBLE_MIN_WIDTH 20    // 语音 最大宽度
#define VOICEBUBBLE_Max_HEIGHT 40

#define ANIMATION_IMAGEVIEW_SIZE 25 // 小喇叭图片尺寸
#define ANIMATION_IMAGEVIEW_SPEED 1 // 小喇叭动画播放速度

#define ANIMATION_TIME_IMAGEVIEW_PADDING 5 // 时间与动画间距

#define ANIMATION_TIME_LABEL_WIDHT 25.f // 时间宽度
#define ANIMATION_TIME_LABEL_HEIGHT 15 // 时间高度
#define ANIMATION_TIME_LABEL_PADDING 5 //间隔

#define UNREAD_WIDTH 10.f
#define ANIMATEDIMAGE_WIDTH 30.f

#import "ChatAudioBubbleView.h"
#import "EMChatVoice.h"
#import "EMVoiceMessageBody.h"

@interface ChatAudioBubbleView ()

@end

@implementation ChatAudioBubbleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_playImageView) {
            _playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ANIMATEDIMAGE_WIDTH, ANIMATEDIMAGE_WIDTH)];
            [self addSubview:_playImageView];
        }
        if (!_durationLabel) {
            _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_TIME_LABEL_WIDHT, ANIMATION_TIME_LABEL_HEIGHT)];
            _durationLabel.font = [UIFont boldSystemFontOfSize:12.f];
            _durationLabel.backgroundColor = [UIColor clearColor];
            _durationLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self addSubview:_durationLabel];
        }
        if (!_unReadView) {
            _unReadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UNREAD_WIDTH, UNREAD_WIDTH)];
            _unReadView.layer.cornerRadius = UNREAD_WIDTH / 2;
            _unReadView.layer.masksToBounds = YES;
            _unReadView.backgroundColor = [UIColor colorWithHexString:@"0xe42f45"];
            [self addSubview:_unReadView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = _durationLabel.frame;
    if (self.isSender) {
        frame.origin.x = CGRectGetMinX(_bgView.frame) - ANIMATION_TIME_LABEL_PADDING - ANIMATION_TIME_LABEL_WIDHT;
        frame.origin.y = (CGRectGetHeight(self.frame) - ANIMATION_TIME_LABEL_HEIGHT)/2;
        [_durationLabel setFrame:frame];
        
        [_playImageView setCenter:CGPointMake(CGRectGetMaxX(_bgView.frame) - ANIMATION_TIME_LABEL_PADDING - BUBBLE_ARROW_WIDTH - ANIMATEDIMAGE_WIDTH/2, CGRectGetMidY(_bgView.frame))];
        
        [_unReadView setHidden:YES];
    } else {
        frame.origin.x = CGRectGetMaxX(_bgView.frame) + ANIMATION_TIME_LABEL_PADDING;
        frame.origin.y = (CGRectGetHeight(self.frame) - ANIMATION_TIME_LABEL_HEIGHT)/2;
        [_durationLabel setFrame:frame];
        
        [_playImageView setCenter:CGPointMake(CGRectGetMinX(_bgView.frame) + ANIMATION_TIME_LABEL_PADDING + BUBBLE_ARROW_WIDTH + ANIMATEDIMAGE_WIDTH/2, CGRectGetMidY(_bgView.frame))];
        
        [_unReadView setCenter:CGPointMake(CGRectGetMaxX(_bgView.frame), CGRectGetMinY(_bgView.frame))];
    }
    //设置语音时间
    self.durationLabel.text = [NSString stringWithFormat:@"%@\"",@(self.duration)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    //语音最多时间为60s
    CGFloat width = BUBBLE_VIEW_PADDING*2 + BUBBLE_ARROW_WIDTH + VOICEBUBBLE_MIN_WIDTH + self.duration * ((VOICEBUBBLE_MAX_WIDTH - VOICEBUBBLE_MIN_WIDTH)/60.f);
    
    CGFloat maxHeight = ANIMATION_IMAGEVIEW_SIZE;
    CGFloat height = BUBBLE_VIEW_PADDING*2 + maxHeight;
    
    return CGSizeMake(width, height);
}
@end
