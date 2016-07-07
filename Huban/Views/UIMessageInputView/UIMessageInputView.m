//
//  UIMessageInputView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kKeyboardView_Height 186.f
#define kMessageInputView_HeightMax 120.0
#define kMessageInputView_PadingHeight 7
#define kMessageInputView_PadingLeft 6.f
#define kMessageInputView_Width_Tool 25.f

#import "UIMessageInputView.h"
#import "UIPlaceHolderTextView.h"
#import "UIMessageInputView_Add.h"
#import "AudioRecordView.h"

//at某人的功能
#import "Login.h"

#import "UICustomCollectionView.h"
#import "QBImagePickerController.h"
#import "Helper.h"
#import "TopicComment.h"

static NSMutableDictionary *_inputStrDict;


@interface UIMessageInputView () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>


@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView; //表情键盘
@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView; //更多键盘
@property (strong, nonatomic) AudioRecordView *recordView;

@property (strong, nonatomic) UIScrollView *contentView;
@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@property (strong, nonatomic) UIButton *voiceActionButton;

@property (strong, nonatomic) UIButton *addButton, *emotionButton, *voiceButton;

@property (assign, nonatomic) CGFloat viewHeightOld;

@property (assign, nonatomic) UIMessageInputViewState inputState;
@end

@implementation UIMessageInputView
- (void)setFrame:(CGRect)frame {
    CGFloat oldHeightToBottom = kScreen_Height - CGRectGetMinY(self.frame);
    CGFloat newHeightToBottom = kScreen_Height - CGRectGetMinY(frame);
    [super setFrame:frame];
    if (oldHeightToBottom > newHeightToBottom) {//降下去的时候保存
        [self saveInputStr];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:heightToBottomChenged:)]) {
        [self.delegate messageInputView:self heightToBottomChenged:newHeightToBottom];
    }
}

- (void)setInputState:(UIMessageInputViewState)inputState {
    if (_inputState != inputState) {
        _inputState = inputState;
        switch (_inputState) {
            case UIMessageInputViewStateSystem:
            {
                [self.addButton setImage:[UIImage imageNamed:@"input_more"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"input_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"input_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [self.addButton setImage:[UIImage imageNamed:@"input_more"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"input_keyboard"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"input_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [self.addButton setImage:[UIImage imageNamed:@"input_keyboard"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"input_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"input_voice"] forState:UIControlStateNormal];
            }
                break;
            case UIMessageInputViewStateVoice:
            {
                [self.addButton setImage:[UIImage imageNamed:@"input_more"] forState:UIControlStateNormal];
                [self.emotionButton setImage:[UIImage imageNamed:@"input_emotion"] forState:UIControlStateNormal];
                [self.voiceButton setImage:[UIImage imageNamed:@"input_keyboard"] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
        _contentView.hidden = _inputState == UIMessageInputViewStateVoice;
        _voiceActionButton.hidden = !_contentView.hidden;
        
        [self updateContentView];
        CGPoint curCenter = _voiceActionButton.center;
        curCenter.y = kMessageInputView_Height/2;
        curCenter.x = _contentView.center.x;
        [_voiceActionButton setCenter:curCenter];
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    if (_inputTextView && ![_inputTextView.placeholder isEqual:placeHolder]) {
        _placeHolder = placeHolder;
        _inputTextView.placeholder = _placeHolder;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [self addLineUp:YES andDown:NO andColor:[UIColor lightGrayColor]];
        _viewHeightOld = CGRectGetHeight(frame);
        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = NO;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Remember input
- (NSMutableDictionary *)shareInputStrDict {
    if (!_inputStrDict) {
        _inputStrDict = [[NSMutableDictionary alloc] init];
    }
    return _inputStrDict;
}

- (NSString *)inputKey{
    NSString *inputKey = nil;
    if (_contentType == UIMessageInputViewContentTypeChat) {
        inputKey = [NSString stringWithFormat:@"privateMessage_%@", self.feedbackComment.feedbackcode];
    }else{
        if (_commentOfId) {
            inputKey = [NSString stringWithFormat:@"tweet_%@_%@", _commentOfId.stringValue, self.feedbackComment.feedbackcode.length > 0? self.feedbackComment.feedbackcode:@""];
        }
    }
    return inputKey;
}

- (NSString *)inputStr{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        return [[self shareInputStrDict] objectForKey:inputKey];
    }
    return nil;
}

- (void)deleteInputData{
    NSString *inputKey = [self inputKey];
    if (inputKey) {
        [[self shareInputStrDict] removeObjectForKey:inputKey];
    }
}

- (void)saveInputStr{
    NSString *inputStr = _inputTextView.text;
    NSString *inputKey = [self inputKey];
    if (inputKey && inputKey.length > 0) {
        if (inputStr && inputStr.length > 0) {
            [[self shareInputStrDict] setObject:inputStr forKey:inputKey];
        }else{
            [[self shareInputStrDict] removeObjectForKey:inputKey];
        }
    }
}

- (void)setFeedbackComment:(TopicComment *)feedbackComment {
    _feedbackComment = feedbackComment;
    NSString *inputStr = [self inputStr];
    if (_inputTextView) {
        if (_contentType == UIMessageInputViewContentTypeComment) {
            self.placeHolder = self.feedbackComment.feedbackname? [NSString stringWithFormat:@"回复: %@", self.feedbackComment.username]: @"编辑评论";
        }
        _inputTextView.selectedRange = NSMakeRange(0, _inputTextView.text.length);
        [_inputTextView insertText:inputStr? inputStr: @""];
    }
}

#pragma mark - Public Method
- (void)prepareToShow{
    if ([self superview] == kKeyWindow) {
        return;
    }
    [self setY:kScreen_Height];
    [kKeyWindow addSubview:self];
    [kKeyWindow addSubview:_emojiKeyboardView];
    [kKeyWindow addSubview:_addKeyboardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if (_isAlwaysShow && ![self isCustomFirstResponder]) {
        [UIView animateWithDuration:0.25 animations:^{
            [self setY:kScreen_Height - CGRectGetHeight(self.frame)];
        }];
    }
}

- (void)prepareToDismiss{
    if ([self superview] == nil) {
        return;
    }
    [self isAndResignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [_emojiKeyboardView removeFromSuperview];
        [_addKeyboardView removeFromSuperview];
        [_recordView removeFromSuperview];
        [self removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)notAndBecomeFirstResponder{
    self.inputState = UIMessageInputViewStateSystem;
    if ([_inputTextView isFirstResponder]) {
        return NO;
    }else{
        [_inputTextView becomeFirstResponder];
        return YES;
    }
}

- (BOOL)isAndResignFirstResponder{
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            if (self.isAlwaysShow) {
                [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        return YES;
    }else{
        if ([_inputTextView isFirstResponder]) {
            [_inputTextView resignFirstResponder];
            return YES;
        }else{
            return NO;
        }
    }
}

- (BOOL)isCustomFirstResponder{
    return ([_inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice);
}

+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type {
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView customUIWithType:type];
    return messageInputView;
}

- (void)customUIWithType:(UIMessageInputViewContentType)type {
    _contentType = type;
    CGFloat contentViewHeight = kMessageInputView_Height - 2*kMessageInputView_PadingHeight;
    
    NSInteger toolBtnNum;
    BOOL hasEmotionBtn, hasAddBtn, hasPhotoBtn, hasVoiceBtn;
    BOOL showBigEmotion;
    
    
    switch (_contentType) {
        case UIMessageInputViewContentTypeComment:
        {
            toolBtnNum = 1;
            hasEmotionBtn = YES;
            hasAddBtn = NO;
            hasPhotoBtn = NO;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
        }
            break;
        case UIMessageInputViewContentTypeChat:
        {
            toolBtnNum = 2;
            hasEmotionBtn = YES;
            hasAddBtn = YES;
            hasPhotoBtn = NO;
            showBigEmotion = YES;
            hasVoiceBtn = YES;
        }
            break;
        default:
            toolBtnNum = 1;
            hasEmotionBtn = NO;
            hasAddBtn = NO;
            hasPhotoBtn = NO;
            showBigEmotion = NO;
            hasVoiceBtn = NO;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.layer.borderWidth = 0.5;
        _contentView.layer.cornerRadius = 5.f;
        _contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _contentView.layer.masksToBounds = YES;
        _contentView.alwaysBounceVertical = YES;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat left = hasVoiceBtn ? (kMessageInputView_Width_Tool + 2*kMessageInputView_PadingLeft) : kMessageInputView_PadingLeft;
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kMessageInputView_PadingHeight, left, kMessageInputView_PadingHeight, kMessageInputView_PadingLeft + toolBtnNum *(kMessageInputView_Width_Tool+kMessageInputView_PadingLeft)));
        }];
    }
    
    if (!_inputTextView) {
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - kMessageInputView_PadingLeft - toolBtnNum *(kMessageInputView_Width_Tool+kMessageInputView_PadingLeft) - (hasVoiceBtn ? (kMessageInputView_Width_Tool + 2*kMessageInputView_PadingLeft) : kMessageInputView_PadingLeft), contentViewHeight)];
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.textColor = SYSFONTCOLOR_BLACK;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO;
        _inputTextView.delegate = self;
        
        //输入框缩进
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;
        [self.contentView addSubview:_inputTextView];
    }
    //输入框
    if (_inputTextView) {
        [[RACObserve(self.inputTextView, contentSize) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSValue *contentSize) {
            [weakSelf updateContentView];
        }];
    }
    
    
    if (hasEmotionBtn && !_emotionButton) {
        _emotionButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - toolBtnNum*(kMessageInputView_Width_Tool+kMessageInputView_PadingLeft), (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        [_emotionButton setImage:[UIImage imageNamed:@"input_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_emotionButton];
    }
    _emotionButton.hidden = !hasEmotionBtn;
    
    if (hasAddBtn && !_addButton) {
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - (kMessageInputView_Width_Tool+kMessageInputView_PadingLeft), (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        
        [_addButton setImage:[UIImage imageNamed:@"input_more"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
    }
    _addButton.hidden = !hasAddBtn;
    
    if (hasEmotionBtn && !_emojiKeyboardView) {
        _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height) dataSource:self];
        [_emojiKeyboardView addLineUp:YES andDown:NO];
        _emojiKeyboardView.delegate = self;
        [_emojiKeyboardView setY:kScreen_Height];
    }
    
    if (hasAddBtn && !_addKeyboardView) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        [_addKeyboardView addLineUp:YES andDown:NO];
        _addKeyboardView.addIndexBlock = ^(NSInteger index){
            if ([weakSelf.delegate respondsToSelector:@selector(messageInputView:addIndexClicked:)]) {
                [weakSelf.delegate messageInputView:weakSelf addIndexClicked:index];
            }
        };
    }
    
    if (hasVoiceBtn && !_voiceButton) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(kMessageInputView_PadingLeft, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool)];
        [_voiceButton setImage:[UIImage imageNamed:@"input_voice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_voiceButton];
    }
    _voiceButton.hidden = !hasVoiceBtn;
    
    if (hasVoiceBtn && !_voiceActionButton) {
        _voiceActionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - kMessageInputView_PadingLeft - toolBtnNum *(kMessageInputView_Width_Tool+kMessageInputView_PadingLeft) - (hasVoiceBtn ? (kMessageInputView_Width_Tool + 2*kMessageInputView_PadingLeft) : kMessageInputView_PadingLeft), contentViewHeight)];
        _voiceActionButton.layer.borderWidth = 0.5;
        _voiceActionButton.layer.cornerRadius = 5.f;
        _voiceActionButton.layer.masksToBounds = YES;
        _voiceActionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _voiceActionButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _voiceActionButton.hidden = YES;
        [_voiceActionButton setTitleColor:SYSFONTCOLOR_BLACK forState:UIControlStateNormal];
        [_voiceActionButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_voiceActionButton setTitle:@"松开 发送" forState:UIControlStateHighlighted];
        [_voiceActionButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xf8f8f8"]] forState:UIControlStateNormal];
        [_voiceActionButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xd3d3d3"]] forState:UIControlStateHighlighted];
        [_voiceActionButton addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_voiceActionButton addTarget:self action:@selector(recordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_voiceActionButton addTarget:self action:@selector(recordButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceActionButton addTarget:self action:@selector(recordDragOutside:) forControlEvents:UIControlEventTouchDragExit];
        [_voiceActionButton addTarget:self action:@selector(recordDragInside:) forControlEvents:UIControlEventTouchDragEnter];
        [self addSubview:_voiceActionButton];
    }
    
    if (!_recordView) {
        _recordView = [AudioRecordView audioRecoredView];
        @weakify(self);
        _recordView.didFinishRecording = ^ (NSString *file,NSTimeInterval duration) {
            @strongify(self);
            if (self.delegate && [self.delegate respondsToSelector:@selector(messageInputView:sendVoice:duration:)]) {
                [self.delegate messageInputView:self sendVoice:file duration:duration];
            }
        };
    }
}

- (void)updateContentView {
    CGSize textSize = _inputTextView.contentSize, mediaSize = CGSizeZero;
    if (ABS(CGRectGetHeight(_inputTextView.frame) - textSize.height) > 0.5) {
        [_inputTextView setHeight:textSize.height];
    }
    
    if (_contentView.hidden) {
        textSize.height = kMessageInputView_Height - 2*kMessageInputView_PadingHeight;
    }
    CGSize contentSize = CGSizeMake(textSize.width, textSize.height + mediaSize.height);
    CGFloat selfHeight = MAX(kMessageInputView_Height, contentSize.height + 2*kMessageInputView_PadingHeight);
    
    CGFloat maxSelfHeight;
    if (kDevice_Is_iPhone5){
        maxSelfHeight = 230;
    }else if (kDevice_Is_iPhone6) {
        maxSelfHeight = 290;
    }else if (kDevice_Is_iPhone6Plus){
        maxSelfHeight = kScreen_Height/2;
    }else{
        maxSelfHeight = 140;
    }
    
    selfHeight = MIN(maxSelfHeight, selfHeight);
    CGFloat diffHeight = selfHeight - _viewHeightOld;
    if (ABS(diffHeight) > 0.5) {
        CGRect selfFrame = self.frame;
        selfFrame.size.height += diffHeight;
        selfFrame.origin.y -= diffHeight;
        [self setFrame:selfFrame];
        self.viewHeightOld = selfHeight;
    }
    [self.contentView setContentSize:contentSize];
    
    CGFloat bottomY = textSize.height;
    CGFloat offsetY = MAX(0, bottomY - (CGRectGetHeight(self.frame)- 2* kMessageInputView_PadingHeight));
    [self.contentView setContentOffset:CGPointMake(0, offsetY) animated:YES];
}

#pragma mark addButton Method
- (void)addButtonClicked:(id)sender{
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateAdd) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateAdd;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_addKeyboardView setY:endY];
        [_emojiKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY- CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}
- (void)emotionButtonClicked:(id)sender{
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateEmotion) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else{
        self.inputState = UIMessageInputViewStateEmotion;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_emojiKeyboardView setY:endY];
        [_addKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY - CGRectGetHeight(self.frame)];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)voiceButtonClicked:(id)sender {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    } else {
        self.inputState = UIMessageInputViewStateVoice;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kMessageInputView_Height;
    }
    [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_emojiKeyboardView setY:kScreen_Height];
        [_addKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)arrowButtonClicked:(id)sender {
    [self isAndResignFirstResponder];
}

- (void)recordButtonTouchDown:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputViewBeginToRecord:)]) {
        [_delegate messageInputViewBeginToRecord:self];
    }
    [_recordView recordButtonTouchDown];
}

- (void)recordButtonTouchUpOutside:(UIButton *)sender {
    [_recordView recordButtonTouchUpOutside];
}

- (void)recordButtonTouchUpInside:(UIButton *)sender {
    [_recordView recordButtonTouchUpInside];
}

- (void)recordDragOutside:(UIButton *)sender {
    [_recordView recordButtonDragOutside];
}

- (void)recordDragInside:(UIButton *)sender {
    [_recordView recordButtonDragInside];
}

#pragma mark UITextViewDelegate
- (void)sendTextStr {
    NSString *sendStr = self.inputTextView.text;
    if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
    }
    _inputTextView.selectedRange = NSMakeRange(0, _inputTextView.text.length);
    [_inputTextView insertText:@""];
    [self updateContentView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (![self.inputTextView.text hasListenChar]) {
            [self sendTextStr];
        }
        return NO;
    }else if ([text isEqualToString:@"@"]){ //@好友
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.inputState != UIMessageInputViewStateSystem) {
        self.inputState = UIMessageInputViewStateSystem;
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emojiKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.inputState == UIMessageInputViewStateSystem) {
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            if (_isAlwaysShow) {
                [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
        }];
    }
    return YES;
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification {
    if ([aNotification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary *userInfo = [aNotification userInfo];
        CGRect keyboardFrame = [[userInfo objectForKeyedSubscript:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keybardY = keyboardFrame.origin.y;
        CGFloat selfOriginY = keybardY == kScreen_Height?self.isAlwaysShow?kScreen_Height - CGRectGetHeight(self.frame) : kScreen_Height :keybardY - CGRectGetHeight(self.frame);
        if (selfOriginY == self.frame.origin.y) {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        void (^endFrameBlock)() = ^{
            [weakSelf setY:selfOriginY];
        };
        if ([aNotification name] == UIKeyboardWillChangeFrameNotification) {
            NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
            [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
                endFrameBlock();
            } completion:nil];
        }else{
            endFrameBlock();
        }
    }
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    [self.inputTextView insertText:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.inputTextView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [self sendTextStr];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageRecent) {
        img = [UIImage imageNamed:@"input_recent"];
    } else if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"input_face"];
    }
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    if (category == AGEmojiKeyboardViewCategoryImageRecent) {
        img = [UIImage imageNamed:@"input_recent"];
    } else if (category == AGEmojiKeyboardViewCategoryImageEmoji) {
        img = [UIImage imageNamed:@"input_face"];
    }
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"input_delete"];
    return img;
}
@end
