//
//  LabelCCell.m
//  Huban
//
//  Created by sean on 15/8/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "LabelCCell.h"

@interface LabelCCell ()
@property (strong, nonatomic) UILabel *textLabel;
@end

@implementation LabelCCell
- (void)setTextStr:(NSString *)textStr {
    _textStr = textStr;
    if (!_textStr || _textStr.length == 0) {
        return;
    }
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.font = kBaseFont;
        _textLabel.textColor = SYSFONTCOLOR_BLACK;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.layer.cornerRadius = 2.f;
        _textLabel.layer.borderWidth = .5f;
        _textLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [self.contentView addSubview:_textLabel];
    }
    _textLabel.text = _textStr;
}
@end
