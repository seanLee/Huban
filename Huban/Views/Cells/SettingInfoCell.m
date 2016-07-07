//
//  SettingInfoCell.m
//  Huban
//
//  Created by sean on 15/9/23.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kSettingInfoCell_ImageWidth 48.f

#import "SettingInfoCell.h"

@interface SettingInfoCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *accountLabel;
@end

@implementation SettingInfoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] init];
            [self.contentView addSubview:_userIconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] init];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            _nameLabel.font = [UIFont boldSystemFontOfSize:14.f];
            _nameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_nameLabel];
        }
        if (!_accountLabel) {
            _accountLabel = [[UILabel alloc] init];
            _accountLabel.textAlignment = NSTextAlignmentLeft;
            _accountLabel.font = [UIFont systemFontOfSize:13.f];
            _accountLabel.textColor = SYSFONTCOLOR_BLACK;
            _accountLabel.hidden = YES;
            [self.contentView addSubview:_accountLabel];
        }
        [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kSettingInfoCell_ImageWidth);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userIconView);
            make.left.equalTo(_userIconView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.equalTo(_userIconView.mas_height).dividedBy(2);
        }];
        [_accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nameLabel.mas_bottom);
            make.left.equalTo(_userIconView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.equalTo(_userIconView.mas_height).dividedBy(2);
        }];
    }
    return self;
}

- (void)setCurUser:(User *)curUser {
    _curUser = curUser;
    if (!_curUser) {
        return;
    }
    [_userIconView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    _nameLabel.text = _curUser.username;
    if (_curUser.useruid.length != 0) {
        _accountLabel.hidden = NO;
        _accountLabel.text = [NSString stringWithFormat:@"呼伴号: %@",_curUser.useruid];
    }
}

+ (CGFloat)cellHeight {
    return 66.f;
}
@end
