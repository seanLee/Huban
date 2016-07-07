//
//  TextFieldCell.m
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TextFieldCell.h"

@interface TextFieldCell ()
@property (strong, nonatomic) UITextField *inputField;
@end

@implementation TextFieldCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_inputField) {
            _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
            _inputField.font = kBaseFont;
            _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _inputField.textColor = SYSFONTCOLOR_BLACK;
            [_inputField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_inputField];
        }
        [_inputField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo([[self class] cellHeight]);
        }];
    }
    return self;
}

- (void)setPlacerStr:(NSString *)placerStr {
    _inputField.placeholder = placerStr;
}

+ (CGFloat)cellHeight {
    return 44.f;
}

- (void)setIsSecret:(BOOL)isSecret {
    _isSecret = isSecret;
    if (_isSecret) {
        _inputField.secureTextEntry = YES;
    }
}

#pragma mark - Action
- (void)textChanged:(UITextField *)sender {
    if (_textChangedBlock) {
        _textChangedBlock(_inputField.text);
    }
}
@end
