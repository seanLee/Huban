//
//  InputTextCell.m
//  Huban
//
//  Created by sean on 15/8/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCell_LeftPading 12.f
#define kCell_LabelPadding 10.f
#define kTitleLabel_Width 55.f
#define kCell_CaptchaButtonWidth  82.f

#import "InputTextCell.h"
#import "TKRoundedView.h"

@interface InputTextCell ()
@property (strong, nonatomic) UILabel *cellTitleLabel;
@property (strong, nonatomic) UITextField *cellEditTextFiled;
@property (strong, nonatomic) TKRoundedView *roundedView;
@end

@implementation InputTextCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!_roundedView) {
            _roundedView = [[TKRoundedView alloc] initWithFrame:self.bounds];
            _roundedView.fillColor = SYSBACKGROUNDCOLOR_DEFAULT;
            _roundedView.borderWidth = .5f;
            _roundedView.cornerRadius = 5.f;
            _roundedView.borderColor = [UIColor colorWithHexString:@"0xd6d6d6"];
            [self.contentView addSubview:_roundedView];
        }
        if (!_cellTitleLabel) {
            _cellTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCell_LeftPading, 0, kTitleLabel_Width, self.frame.size.height)];
            _cellTitleLabel.font = kBaseFont;
            _cellTitleLabel.textColor = SYSFONTCOLOR_BLACK;
            _cellTitleLabel.textAlignment = NSTextAlignmentLeft;
            [_roundedView addSubview:_cellTitleLabel];
        }
        if (!_cellEditTextFiled) {
            _cellEditTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
            _cellEditTextFiled.textColor = [UIColor colorWithHexString:@"0x666666"];
            _cellEditTextFiled.font = kBaseFont;
            [_cellEditTextFiled addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [_roundedView addSubview:_cellEditTextFiled];
        }
        if (!_captchaButton) {
            _captchaButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _captchaButton.titleLabel.font = kBaseFont;
            _captchaButton.hidden = YES;
            [_captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_captchaButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0x69ccff"]] forState:UIControlStateNormal];
            [_captchaButton setBackgroundImage:[UIImage imageWithColor:[[UIColor colorWithHexString:@"0x69ccff"] colorWithAlphaComponent:.5f]] forState:UIControlStateDisabled];
            [_captchaButton setTitleColor:[UIColor colorWithHexString:@"0xFFFFFF"] forState:UIControlStateNormal];
            [_captchaButton setTitleColor:[[UIColor colorWithHexString:@"0xFFFFFF"] colorWithAlphaComponent:.3f] forState:UIControlStateHighlighted];
            [_captchaButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_roundedView addSubview:_captchaButton];
        }
        [_roundedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [_cellTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_roundedView).offset(kCell_LeftPading);
            make.top.equalTo(_roundedView);
            make.height.equalTo(_roundedView);
            make.width.mas_equalTo(kTitleLabel_Width);
        }];
        [_cellEditTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_cellTitleLabel.mas_right).offset(kCell_LabelPadding);
            make.top.equalTo(_roundedView);
            make.height.equalTo(_roundedView);
            make.right.equalTo(_roundedView).offset(-kCell_LeftPading);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_topRounded) {
        _roundedView.roundedCorners = TKRoundedCornerTopLeft | TKRoundedCornerTopRight;
    } else if (_bottomRounded) {
        _roundedView.roundedCorners = TKRoundedCornerBottomRight | TKRoundedCornerBottomLeft;
        _roundedView.drawnBordersSides = TKDrawnBorderSidesLeft | TKDrawnBorderSidesRight | TKDrawnBorderSidesBottom;
    } else {
        _roundedView.roundedCorners = TKRoundedCornerNone;
        _roundedView.drawnBordersSides = TKDrawnBorderSidesLeft | TKDrawnBorderSidesRight | TKDrawnBorderSidesBottom;
    }
    
    if (_showCaptchaButton) {
        _captchaButton.hidden = NO;
        [_captchaButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_roundedView).offset(-kCell_LeftPading);
            make.width.mas_equalTo(kCell_CaptchaButtonWidth);
            make.height.mas_equalTo(30);
            make.centerY.equalTo(_roundedView);
        }];
        [_cellEditTextFiled mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_cellTitleLabel.mas_right).offset(kCell_LabelPadding);
            make.right.equalTo(_captchaButton.mas_left).offset(-kCell_LeftPading);
            make.top.equalTo(_roundedView);
            make.height.equalTo(_roundedView);
        }];
    }
}

- (void)setIsSecret:(BOOL)isSecret {
    _cellEditTextFiled.secureTextEntry = isSecret;
    _cellEditTextFiled.clearsOnBeginEditing = YES;
}

- (void)setTitleStr:(NSString *)title andPlaceholderStr:(NSString *)placeholder {
    if (title) {
        _cellTitleLabel.text = title;
    }
    if (placeholder) {
        _cellEditTextFiled.placeholder = placeholder;
    }
}

- (void)textValueChanged:(id)sender {
    if (self.inputBlock) {
        self.inputBlock(self.cellEditTextFiled.text);
    }
}

- (void)buttonClicked:(id)sender {
    if (_captchaClicked) {
        _captchaClicked();
    }
}

+ (CGFloat)cellHeight {
    return 46.f;
}
@end
