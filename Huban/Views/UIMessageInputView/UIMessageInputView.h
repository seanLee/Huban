//
//  UIMessageInputView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kMessageInputView_Height 50.f

#import <UIKit/UIKit.h>
#import "AGEmojiKeyBoardView.h"
@class TopicComment;


typedef NS_ENUM(NSInteger, UIMessageInputViewContentType) {
    UIMessageInputViewContentTypeChat = 0,
    UIMessageInputViewContentTypeComment
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,
    UIMessageInputViewStateEmotion,
    UIMessageInputViewStateAdd,
    UIMessageInputViewStateVoice
};
@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView : UIView<UITextViewDelegate>
@property (strong, nonatomic) NSString *placeHolder;
@property (assign, nonatomic) BOOL isAlwaysShow;
@property (assign, nonatomic, readonly) UIMessageInputViewContentType contentType;
@property (strong, nonatomic) TopicComment *feedbackComment;
@property (strong, nonatomic) NSNumber *commentOfId;

@property (nonatomic, weak) id<UIMessageInputViewDelegate> delegate;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
- (BOOL)isCustomFirstResponder;
@end

@protocol UIMessageInputViewDelegate <NSObject>
@optional
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text;
- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;
- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration;
- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index;
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom;

- (void)messageInputViewBeginToRecord:(UIMessageInputView *)inputView;
@end
