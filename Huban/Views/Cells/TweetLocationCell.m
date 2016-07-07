//
//  TweetLocationCell.m
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetLocationCell_CheckmarkWidth 24.f

#import "TweetLocationCell.h"

@interface TweetLocationCell ()
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UIButton *checkmarkButton;
@end

@implementation TweetLocationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_locationLabel) {
            _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _locationLabel.font = kBaseFont;
            _locationLabel.textColor = SYSFONTCOLOR_BLACK;
            _locationLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_locationLabel];
        }
        if (!_checkmarkButton) {
            _checkmarkButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [_checkmarkButton setImage:[UIImage imageNamed:@"checkmark_Box"] forState:UIControlStateNormal];
            [_checkmarkButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateSelected];
            [self.contentView addSubview:_checkmarkButton];
        }
        [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.bottom.equalTo(self.contentView);
            make.right.equalTo(_checkmarkButton.mas_left).offset(-kPaddingLeftWidth);
        }];
        [_checkmarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kTweetLocationCell_CheckmarkWidth);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)setShowCheckmark:(BOOL)showCheckmark {
    _showCheckmark = showCheckmark;
    _checkmarkButton.selected = _showCheckmark;
}

- (void)setTextStr:(NSString *)textStr {
    _locationLabel.text = textStr;
}

+ (CGFloat)cellHeight {
    return 44.f;
}
@end
