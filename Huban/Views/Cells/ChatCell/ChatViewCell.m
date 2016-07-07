//
//  ChatViewCell.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define SEND_STATUS_SIZE 20 // 发送状态View的Size

#import "ChatViewCell.h"
#import "ChatTextBubbleView.h"
#import "ChatAudioBubbleView.h"
#import "ChatImageBubbleView.h"
#import "ChatLocationBubbleView.h"

@interface ChatViewCell ()
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) UIView *activityView;
@property (strong, nonatomic) UIButton *retryButton;
@property (strong, nonatomic) UIView *messageStateView;
@end

@implementation ChatViewCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier andMessage:(EaseMessageModel *)message {
    self = [super initWithReuseIdentifier:reuseIdentifier andMessage:message];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bubbleFrame = self.bubbleView.frame;
    bubbleFrame.origin.y = self.userIconView.frame.origin.y;
    
    if (self.curMessage.isSender) {
        switch (self.curMessage.messageStatus) {
            case eMessageDeliveryState_Delivering: {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activity setHidden:NO];
                [_activity startAnimating];
            }
                break;
            case eMessageDeliveryState_Delivered: {
                [_activityView setHidden:YES];
                [_retryButton setHidden:YES];
                [_activity stopAnimating];
                [_activity setHidden:YES];
            }
                break;
            case eMessageDeliveryState_Failure: {
                [_activityView setHidden:NO];
                [_activity stopAnimating];
                [_activity setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        //bubbleView
        bubbleFrame.origin.x = self.userIconView.frame.origin.x - bubbleFrame.size.width - kPaddingLeftWidth;
        [self.bubbleView setFrame:bubbleFrame];
        
        CGRect statusFrame = _messageStateView.frame;
        statusFrame.origin.x = bubbleFrame.origin.x - kPaddingLeftWidth - SEND_STATUS_SIZE;
        statusFrame.origin.y = (bubbleFrame.size.height - statusFrame.size.height)/2;
        [_messageStateView setFrame:statusFrame];
        
    } else {
        bubbleFrame.origin.x = kPaddingLeftWidth*2 + kChatViewBasicCell_HeaderWidth;
        if (self.curMessage.messageType != eMessageTypeChat) {
            bubbleFrame.origin.y = NAME_LABEL_HEIGHT + NAME_LABEL_PADDING;
        }
        [self.bubbleView setFrame:bubbleFrame];
    }
}

- (void)setCurMessage:(EaseMessageModel *)curMessage {
    [super setCurMessage:curMessage];
    if (curMessage.messageType != eMessageTypeChat) {
        self.nameLabel.text = curMessage.message.from;
        self.nameLabel.hidden = [curMessage isSender];
    }
    //设置头像
    UIImage *bgImage;
    if ([self.curMessage isSender]) { //如果发送的人是自己
        bgImage = [UIImage imageNamed:@"messageBox_right"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30.f, 30.f, bgImage.size.height - 31.f, bgImage.size.width - 31.f)];
    } else {
        bgImage = [UIImage imageNamed:@"messageBox_left"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30.f, 30.f, bgImage.size.height - 31.f, bgImage.size.width - 31.f)];
    }
    self.bubbleView.isSender = [self.curMessage isSender];
    self.bubbleView.bgView.image = bgImage;
    //设置数据
    switch (curMessage.bodyType) {
        case eMessageBodyType_Text: {
            ChatTextBubbleView *textView = (ChatTextBubbleView *)self.bubbleView;
            textView.isSender = curMessage.isSender;
            textView.messageText = self.curMessage.text;
            textView.contentLabel.text = self.curMessage.text;
        }
            break;
        case eMessageBodyType_Image: {
            ChatImageBubbleView *imageView = (ChatImageBubbleView *)self.bubbleView;
            imageView.isSender = curMessage.isSender;
            UIImage *image = self.curMessage.isSender?self.curMessage.image:self.curMessage.thumbnailImage;
            if (!image) {
                image = self.curMessage.image;
                if (!image) {
                    [imageView.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.curMessage.fileURLPath] placeholderImage:[UIImage imageNamed:self.curMessage.failImageName]];
                } else {
                    imageView.contentImageView.image = image;
                }
            } else {
                imageView.contentImageView.image = image;
            }
        }
            break;
        case eMessageBodyType_Location: {
            ChatLocationBubbleView *locationView = (ChatLocationBubbleView *)self.bubbleView;
            locationView.isSender = curMessage.isSender;
            UIImage *bgImage = [UIImage imageNamed:@"chat_location_preview"];
            locationView.locationImgView.image = [bgImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            NSArray *locationArr = [self.curMessage.address componentsSeparatedByString:@","];
            locationView.locationInfoLbl.text = [locationArr firstObject];
        }
            break;
        case eMessageBodyType_Voice: {
            ChatAudioBubbleView *voiceView = (ChatAudioBubbleView *)self.bubbleView;
            voiceView.duration = curMessage.mediaDuration;
            voiceView.unReadView.hidden = curMessage.isMediaPlayed;
            voiceView.isSender = curMessage.isSender;
            //语音时间
            voiceView.playImageView.animationDuration = 1.f;
            //设置语音的图片
            if ([self.curMessage isSender]) {
                voiceView.playImageView.image = [UIImage imageNamed:@"animated_voice_left_3"];
                voiceView.playImageView.animationImages = @[[UIImage imageNamed:@"animated_voice_left_3"],[UIImage imageNamed:@"animated_voice_left_1"],[UIImage imageNamed:@"animated_voice_left_2"]];
            } else {
                voiceView.playImageView.image = [UIImage imageNamed:@"animated_voice_right_3"];
                voiceView.playImageView.animationImages = @[[UIImage imageNamed:@"animated_voice_right_3"],[UIImage imageNamed:@"animated_voice_right_1"],[UIImage imageNamed:@"animated_voice_right_2"]];
            }
            //播放语音的动画
            if (self.curMessage.isMediaPlaying) {
                [voiceView.playImageView startAnimating];
            } else {
                [voiceView.playImageView stopAnimating];
            }
        }
            break;
        default:
            break;
    }
    [self.bubbleView sizeToFit];
    [self.bubbleView setNeedsLayout];
}

#pragma mark - Private
- (void)setupSubviewsWithObj:(EaseMessageModel *)message {
    [super setupSubviewsWithObj:message];
    self.bubbleView = [self bubbleViewForMessageType:message];
    [self.contentView addSubview:self.bubbleView];
}

- (ChatBaseBubbleView *)bubbleViewForMessageType:(EaseMessageModel *)message {
    __weak typeof(self) weakSelf = self;
    ChatBaseBubbleView *bubbleView;
    switch (message.bodyType) {
        case eMessageBodyType_Text: {
            bubbleView = [[ChatTextBubbleView alloc] init];
            [bubbleView.bgView addLongPressMenu:@[@"复制",@"删除"] clickBlock:^(NSInteger index, NSString *title) {
                if (index == 0) {
                    if (weakSelf.copyTextBlock) {
                        weakSelf.copyTextBlock();
                    }
                } else if (index == 1) {
                    [weakSelf deleteMessage:message];
                }
            }];
            [bubbleView.bgView addSingleTapWithBlock:^{
                if (weakSelf.didTapCellBlock) {
                    weakSelf.didTapCellBlock();
                }
            }];
        }
            break;
        case eMessageBodyType_Voice: {
            bubbleView = [[ChatAudioBubbleView alloc] init];
            [bubbleView.bgView addLongPressMenu:@[@"删除"] clickBlock:^(NSInteger index, NSString *title) {
                if (index == 0) {
                    [weakSelf deleteMessage:message];
                }
            }];
            [bubbleView.bgView addSingleTapWithBlock:^{
                if (weakSelf.didTapCellBlock) {
                    weakSelf.didTapCellBlock();
                }
            }];
        }
            break;
        case eMessageBodyType_Image: {
            bubbleView = [[ChatImageBubbleView alloc] init];
            [bubbleView.bgView addLongPressMenu:@[@"发送给朋友",@"删除"] clickBlock:^(NSInteger index, NSString *title) {
                if (index == 0) {
                    [weakSelf transpondMessage:message];
                } else if (index == 1) {
                    [weakSelf deleteMessage:message];
                }
            }];
            @weakify(self);
            [bubbleView.bgView addSingleTapWithBlock:^{
                @strongify(self);
                [self endEditing:YES];
                if (weakSelf.didTapCellBlock) {
                    weakSelf.didTapCellBlock();
                }
            }];
        }
            break;
        case eMessageBodyType_Location: {
            bubbleView = [[ChatLocationBubbleView alloc] init];
            [bubbleView.bgView addLongPressMenu:@[@"删除"] clickBlock:^(NSInteger index, NSString *title) {
                if (index == 0) {
                    [weakSelf deleteMessage:message];
                }
            }];
            [bubbleView.bgView addSingleTapWithBlock:^{
                if (weakSelf.didTapCellBlock) {
                    weakSelf.didTapCellBlock();
                }
            }];
        }
            break;
        default:
            break;
    }
    return bubbleView;
}

+ (CGFloat)bubbleViewHeightForMessage:(EaseMessageModel *)message {
    CGFloat viewHeight;
    switch (message.bodyType) {
        case eMessageBodyType_Text: {
            viewHeight = [ChatTextBubbleView heightForBubbleWithObject:message];
        }
            break;
        case eMessageBodyType_Voice: {
            viewHeight = [ChatAudioBubbleView heightForBubbleWithObject:message];
        }
            break;
        case eMessageBodyType_Image: {
            viewHeight = [ChatImageBubbleView heightForBubbleWithObject:message];
        }
            break;
        case eMessageBodyType_Location: {
            viewHeight = [ChatLocationBubbleView heightForBubbleWithObject:message];
        }
        default:
            break;
    }
    return viewHeight;
}

#pragma mark - UIMenuController Action
- (void)deleteMessage:(EaseMessageModel *)message {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}

- (void)transpondMessage:(EaseMessageModel *)message {
    ChatImageBubbleView *bubbleView = (ChatImageBubbleView *)self.bubbleView;
    if (self.transpondBlock) {
        self.transpondBlock(bubbleView.contentImageView.image);
    }
}

#pragma mark - Public
+ (CGFloat)cellHeightWithObj:(EaseMessageModel *)message {
    CGFloat cellHeight = 0;
    cellHeight = [self bubbleViewHeightForMessage:message];
    if (message.messageType != eMessageTypeChat && !message.isSender) {
        cellHeight += NAME_LABEL_HEIGHT;
    }
    cellHeight = MAX(cellHeight, [super cellHeightWithObj:message]);
    return cellHeight;
}

#pragma mark - Method
@end
