//
//  TitleValueMoreCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTitleRImageMoreCell_LabelWidth 80.f
#define kValueFont [UIFont systemFontOfSize:14.f]
#define kCellMarginTop 7.f
#define kCellOneLine_TextHeight 17.f

#import "TitleValueMoreCell.h"

@interface TitleValueMoreCell ()
@property (strong, nonatomic) UILabel *titleLabel, *valueLabel;
@end

@implementation TitleValueMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7.f, kTitleRImageMoreCell_LabelWidth, 30.f)];
            _titleLabel.font = kValueFont;
            _titleLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, kScreen_Width-(110+kPaddingLeftWidth) - 30, 30)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = kValueFont;
            _valueLabel.numberOfLines = 0;
            _valueLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _valueLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_valueLabel];
        }
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [_valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value{
    _titleLabel.text = title;
    _valueLabel.text = value;
    
    //get the height of string
    CGFloat textHeight = [value getHeightWithFont:kValueFont constrainedToSize:CGSizeMake(kScreen_Width - kTitleRImageMoreCell_LabelWidth - 3*kPaddingLeftWidth, CGFLOAT_MAX)];
    
    //relocate the subviews
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        make.width.mas_equalTo(kTitleRImageMoreCell_LabelWidth);
        make.height.mas_equalTo(MAX(textHeight, 44.f));
        make.centerY.equalTo(self.contentView);
    }];
    [_valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel.mas_right).offset(kPaddingLeftWidth);
        make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo(MAX(textHeight, 44.f));
        make.centerY.equalTo(self.contentView);
    }];

    //先计算出该字体下一行字的高度,如果字体超过一行字,则需要重新给textAlignment
    if (textHeight > kCellOneLine_TextHeight) {
        _valueLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        _valueLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    if (_showIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

+ (CGFloat)cellHeightWithStr:(NSString *)textStr{
    CGFloat textHeight = [textStr getHeightWithFont:kValueFont constrainedToSize:CGSizeMake(kScreen_Width - kTitleRImageMoreCell_LabelWidth - 3*kPaddingLeftWidth, CGFLOAT_MAX)];
    if (textHeight > 44.f) {
        return textHeight + 2*kCellMarginTop;
    }
    return 44.f;
}

@end
