//
//  ContactBookCell.m
//  Huban
//
//  Created by sean on 15/8/16.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kToUserCell_ImageWidth 48.f

#import "ToUserCell.h"

@interface ToUserCell ()
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UILabel *titleL;
@end

@implementation ToUserCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kToUserCell_ImageWidth, kToUserCell_ImageWidth)];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width/2, 20)];
            _titleL.textAlignment = NSTextAlignmentLeft;
            _titleL.font = [UIFont systemFontOfSize:14.f];
            _titleL.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleL];
        }
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(kToUserCell_ImageWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo([[self class] cellHeight]);
        }];
    }
    return self;
}

- (void)setContact:(Contact *)contact {
    _contact = contact;
    [_userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:_contact.contactlogourl] placeholderImage:[UIImage avatarPlacer]];
    _titleL.text = [_contact.contactmemo isEmpty]?_contact.contactname:_contact.contactmemo;
}

+ (CGFloat)cellHeight {
    return 66.f;
}
@end
