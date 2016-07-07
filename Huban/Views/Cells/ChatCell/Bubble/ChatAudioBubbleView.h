//
//  ChatAudioBubbleView.h
//  Huban
//
//  Created by sean on 15/9/16.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ChatBaseBubbleView.h"

@interface ChatAudioBubbleView : ChatBaseBubbleView
@property (strong, nonatomic) UIImageView *playImageView;
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIView *unReadView;
@end
