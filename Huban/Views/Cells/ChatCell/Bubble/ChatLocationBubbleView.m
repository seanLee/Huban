//
//  ChatLocationBubbleView.m
//  Huban
//
//  Created by sean on 15/12/2.
//  Copyright © 2015年 sean. All rights reserved.
//

#define KChatLocationBubbleView_ImageWidth 135.f
#define KChatLocationBubbleView_ImageHeight 79.f
#define KChatLocationBubbleView_LocationHeight 32.5f

#import "ChatLocationBubbleView.h"

@interface ChatLocationBubbleView ()

@end

@implementation ChatLocationBubbleView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _locationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,KChatLocationBubbleView_ImageWidth, KChatLocationBubbleView_ImageHeight)];
        _locationImgView.layer.cornerRadius = 5.f;
        _locationImgView.layer.masksToBounds = YES;
        [self addSubview:_locationImgView];
        
        _locationInfoLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationInfoLbl.font = [UIFont systemFontOfSize:12.f];
        _locationInfoLbl.backgroundColor = [UIColor colorWithWhite:0 alpha:.4f];
        _locationInfoLbl.textColor = [UIColor whiteColor];
        _locationInfoLbl.numberOfLines = 0;
        _locationInfoLbl.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_locationInfoLbl];
        
        [_locationInfoLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_locationImgView);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(KChatLocationBubbleView_LocationHeight);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isSender) {
        [_locationImgView setX:0];
    } else {
        [_locationImgView setX:BUBBLE_ARROW_WIDTH];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(KChatLocationBubbleView_ImageWidth + BUBBLE_ARROW_WIDTH, KChatLocationBubbleView_ImageHeight);
}

#pragma mark - Public
+ (CGFloat)heightForBubbleWithObject:(EaseMessageModel *)message {
    return KChatLocationBubbleView_ImageHeight;
}
@end
