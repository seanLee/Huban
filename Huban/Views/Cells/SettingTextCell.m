//
//  SettingTextCell.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "SettingTextCell.h"
#import "UIPlaceHolderTextView.h"

@interface SettingTextCell () <UITextViewDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *inputTextView;
@end

@implementation SettingTextCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_inputTextView) {
            _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
            _inputTextView.backgroundColor = [UIColor clearColor];
            _inputTextView.font = [UIFont systemFontOfSize:14.f];
            _inputTextView.textColor = SYSFONTCOLOR_BLACK;
            _inputTextView.placeholder = @"未填写";
            _inputTextView.delegate = self;
            [_inputTextView setContentInset:UIEdgeInsetsMake(6.f, 0, 0, 0)];
            [self.contentView addSubview:_inputTextView];
        }
        [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setTextValue:(NSString *)textValue {
    [_inputTextView becomeFirstResponder];
    if ([_inputTextView.text isEqual:@"未填写"]) {
        _textValue = nil;
    } else {
        _textValue = textValue;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _inputTextView.text = _textValue;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.markedTextRange) {
        return;
    }
    _textValue = textView.text;
    if (_textChangeBlock) {
        _textChangeBlock(_textValue);
    }
}
@end
