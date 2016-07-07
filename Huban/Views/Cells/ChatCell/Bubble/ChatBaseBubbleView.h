//
//  ChatBaseBubbleView.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define BUBBLE_ARROW_WIDTH 10 // bubbleView中，箭头的宽度
#define BUBBLE_VIEW_PADDING 8 // bubbleView 与 在其中的控件内边距

#import <UIKit/UIKit.h>
#import "UIGestureImageView.h"
#import "EMMessage.h"

@interface ChatBaseBubbleView : UIView {
    UIGestureImageView *_bgView;
}
@property (strong, nonatomic) UIGestureImageView *bgView;

#pragma mark - Text
@property (strong, nonatomic) NSString *messageText;

#pragma mark - Voice
@property (assign, nonatomic) BOOL isSender;
@property (assign, nonatomic) NSInteger duration;

+ (CGFloat)heightForBubbleWithObject:(EaseMessageModel *)message;
@end
