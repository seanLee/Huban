//
//  AddCustomerRequestCell.m
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAddUserRequestCell_HeaderWidth 48.f
#define kAddUserRequestCell_ButtonWidth 44.f
#define kAddUserRequestCell_ButtonHeight 28.f

#import "AddUserRequestCell.h"

@interface AddUserRequestCell ()
@property (strong, nonatomic) UIImageView *userAvatarView;
@property (strong, nonatomic) UILabel *nickNameLabel;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UIButton *actionButton;
@end

@implementation AddUserRequestCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_userAvatarView) {
            _userAvatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddUserRequestCell_HeaderWidth, kAddUserRequestCell_HeaderWidth)];
            [self.contentView addSubview:_userAvatarView];
        }
        if (!_nickNameLabel) {
            _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAddUserRequestCell_HeaderWidth, kAddUserRequestCell_HeaderWidth/2)];
            _nickNameLabel.font = [UIFont boldSystemFontOfSize:14.f];
            _nickNameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_nickNameLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAddUserRequestCell_HeaderWidth, kAddUserRequestCell_HeaderWidth/2)];
            _userNameLabel.font = kBaseFont;
            _userNameLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_actionButton) {
            _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kAddUserRequestCell_ButtonWidth, kAddUserRequestCell_ButtonHeight)];
            _actionButton.layer.cornerRadius = 5.f;
            _actionButton.layer.borderWidth = .5f;
            _actionButton.titleLabel.font = kBaseFont;
            [_actionButton addTarget:self action:@selector(actionClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_actionButton];
        }
        [_userAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.height.mas_equalTo(kAddUserRequestCell_HeaderWidth);
        }];
        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(kAddUserRequestCell_ButtonWidth);
            make.height.mas_equalTo(kAddUserRequestCell_ButtonHeight);
        }];
    }
    return self;
}

- (void)setCurUser:(User *)curUser {
    _curUser = curUser;
    if (!_curUser) {
        return;
    }
    _nickNameLabel.text = _curUser.username;
    [_nickNameLabel sizeToFit];
    [_nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_userAvatarView);
        make.left.equalTo(_userAvatarView.mas_right).offset(kPaddingLeftWidth);
    }];
    
    _userNameLabel.text =  [NSString stringWithFormat:@"手机联系人:%@",_curUser.username];
    [_userNameLabel sizeToFit];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_userAvatarView);
        make.left.equalTo(_userAvatarView.mas_right).offset(kPaddingLeftWidth);
    }];
    
    [_userAvatarView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
}

- (void)setState:(AddedUserState)state {
    switch (state) {
        case AddedUserStateNewAdded: {
            [_actionButton setTitle:@"添加" forState:UIControlStateNormal];
            [_actionButton setTitleColor:SYSFONTCOLOR_BLACK forState:UIControlStateNormal];
            [_actionButton setBackgroundColor:SYSBACKGROUNDCOLOR_DEFAULT];
            _actionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
            break;
        case AddedUserStateHasAdded: {
            [_actionButton setTitle:@"已添加" forState:UIControlStateNormal];
            [_actionButton setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateNormal];
            [_actionButton setBackgroundColor:[UIColor clearColor]];
            _actionButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
            break;
        case AddedUserStateRequest: {
            [_actionButton setTitle:@"接受" forState:UIControlStateNormal];
            [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_actionButton setBackgroundColor:SYSBACKGROUNDCOLOR_BLUE];
            _actionButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
            break;
        default: {
            [_actionButton setTitle:@"添加" forState:UIControlStateNormal];
            [_actionButton setTitleColor:SYSFONTCOLOR_BLACK forState:UIControlStateNormal];
            [_actionButton setBackgroundColor:SYSBACKGROUNDCOLOR_DEFAULT];
            _actionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
            break;
    }
}

+ (CGFloat)cellHeight {
    return 66.f;
}

#pragma mark - Action
- (void)actionClicked:(id)sender {
    if (_actionClicked) {
        _actionClicked(_curUser);
    }
}
@end
