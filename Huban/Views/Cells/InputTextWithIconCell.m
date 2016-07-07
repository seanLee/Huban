//
//  InputTextWithIconCell.m
//  Huban
//
//  Created by sean on 15/7/30.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kIconButtonWidth 12.f
#define kClearButtonWidth 20.f
#define kPading_Left 8.f
#define kInputTextWithIconCell_PadingLeft 11.f

#import "InputTextWithIconCell.h"
#import "TKRoundedView.h"

@interface InputTextWithIconCell () <UITextFieldDelegate>
@property (strong, nonatomic) TKRoundedView *roundedView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UITextField *inputTextFiled;
@end

@implementation InputTextWithIconCell
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
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kInputTextWithIconCell_PadingLeft, 0, kIconButtonWidth, kIconButtonWidth)];
            [_roundedView addSubview:_iconView];
        }
        if (!_inputTextFiled) {
            _inputTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(4.f, 0, kScreen_Width - kIconButtonWidth - kClearButtonWidth - 2*kInputTextWithIconCell_PadingLeft, [[self class] cellHeight])];
            [_inputTextFiled addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [_inputTextFiled addTarget:self action:@selector(textDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
            _inputTextFiled.font = kBaseFont;
            _inputTextFiled.textColor = [UIColor colorWithHexString:@"0x666666"];
            [_roundedView addSubview:_inputTextFiled];
        }
        [_roundedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_roundedView).offset(kInputTextWithIconCell_PadingLeft);
            make.width.height.mas_equalTo(kIconButtonWidth);
            make.centerY.equalTo(_roundedView);
        }];
        [_inputTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(kPading_Left);
            make.right.equalTo(_roundedView);
            make.top.equalTo(_roundedView);
            make.height.mas_equalTo([[self class] cellHeight]);
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
}

- (void)setIsSecret:(BOOL)isSecret {
    _inputTextFiled.secureTextEntry = isSecret;
    _inputTextFiled.clearsOnBeginEditing = YES;
}

- (void)setPlaceholderStr:(NSString *)placeholderStr {
    _placeholderStr = placeholderStr;
    if (!_placeholderStr || [_placeholderStr isEmpty]) {
        return;
    }
    self.inputTextFiled.placeholder = _placeholderStr;
}

- (void)setLastLoginCode:(NSString *)lastLoginCode{
    _lastLoginCode = lastLoginCode;
    if (!_lastLoginCode || [_lastLoginCode isEmpty]) {
        return;
    }
    self.inputTextFiled.text = _lastLoginCode;
}

- (void)setIconImage:(UIImage *)iconImage {
    _iconImage = iconImage;
    if (!_iconImage) {
        return;
    }
    self.iconView.image = iconImage;
}

+ (CGFloat)cellHeight {
    return 46.f;
}

#pragma mark - Action
- (void)textValueChanged:(id)sender {
    if (_textValueChangedBlock) {
        _textValueChangedBlock(_inputTextFiled.text);
    }
}

- (void)textDidEndEditing:(id)sender {
    if (_textDidEndEditingBlock) {
        _textDidEndEditingBlock(_inputTextFiled.text);
    }
}
@end
