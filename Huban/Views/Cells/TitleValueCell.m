//
//  TitleValueCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTitleValueCell_TitleWidth 70.f

#import "TitleValueCell.h"
@interface TitleValueCell ()
@property (strong, nonatomic) UILabel *titleLabel, *valueLabel;
@property (strong, nonatomic) NSString *title, *value;
@end

@implementation TitleValueCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, kTitleValueCell_TitleWidth, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:14.f];
            _titleLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, kScreen_Width-(120+kPaddingLeftWidth), 30)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = [UIFont systemFontOfSize:14.f];
            _valueLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _valueLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_valueLabel];
        }
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kTitleValueCell_TitleWidth);
            make.height.mas_equalTo([TitleValueCell cellHeight]);
        }];
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];

    _titleLabel.text = _title;
    _valueLabel.text = _value;
}

- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value{
    self.title = title;
    self.value = value;
}

+ (CGFloat)cellHeight {
    return 44.f;
}
@end
