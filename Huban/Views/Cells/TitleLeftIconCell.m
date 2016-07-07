//
//  UserInfoIconCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kTitleFont [UIFont systemFontOfSize:14.f]

#import "TitleLeftIconCell.h"

@interface TitleLeftIconCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UILabel *detailL;
@end

@implementation TitleLeftIconCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, 16.f, 16.f)];
            [self.contentView addSubview:_iconView];
        }
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width/2, 20)];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = kTitleFont;
            _titleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_titleL];
        }
        if (!_detailL) {
            _detailL = [[UILabel alloc] init];
            _detailL.textAlignment = NSTextAlignmentRight;
            _detailL.font = kTitleFont;
            _detailL.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_detailL];
        }
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(16.f);
            make.centerY.equalTo(self.contentView);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo([[self class] cellHeight]);
        }];
        [_detailL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right);
            make.centerY.equalTo(self.contentView);
            make.height.mas_greaterThanOrEqualTo(0);
            make.width.mas_greaterThanOrEqualTo(0);
        }];
    }
    return self;
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    if (_showIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)setTitle:(NSString *)title icon:(NSString *)iconName{
    _titleL.text = title;
    if (iconName.length == 0) {
        return;
    }
    _iconView.image = [UIImage imageNamed:iconName];
}

- (void)setDetailStr:(NSString *)detailText {
    [_detailL fitToText:detailText];
}

- (void)setHasNewIndicator:(BOOL)hasNewIndicator {
    _hasNewIndicator = hasNewIndicator;
    if (_hasNewIndicator) {
        NSString *titleText = _titleL.text;
        //get the title of the cell
        CGFloat titleWidth = [titleText getWidthWithFont:kTitleFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, [[self class] cellHeight])];
        [self.contentView addIndicatorViewWithCenterPoint:CGPointMake(CGRectGetMaxX(_iconView.frame) + 2*kPaddingLeftWidth + titleWidth, self.contentView.center.y)];
    } else {
        [self.contentView removeIndicatorView];
    }
}

+ (CGFloat)cellHeight{
    return 44;
}
@end
