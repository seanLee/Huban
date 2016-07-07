//
//  TitleLeftImageCell.m
//  Huban
//
//  Created by sean on 15/8/13.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTitleLeftImageCell_ImageWidth 48.f

#import "TitleLeftImageCell.h"

@interface TitleLeftImageCell ()
@property (strong, nonatomic) UIImageView *leftImageView;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation TitleLeftImageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        if (!_leftImageView) {
            _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTitleLeftImageCell_ImageWidth, kTitleLeftImageCell_ImageWidth)];
            [self.contentView addSubview:_leftImageView];
        }
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width/2, 20)];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:14.f];
            _titleL.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleL];
        }
        [_leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(kTitleLeftImageCell_ImageWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_leftImageView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo([[self class] cellHeight]);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title bigIcon:(NSString *)iconName{
    _titleL.text = title;
    if (iconName.length == 0) {
        return;
    }
    _leftImageView.image = [UIImage imageNamed:iconName];
}

+ (CGFloat)cellHeight{
    return 66.f;
}
@end
