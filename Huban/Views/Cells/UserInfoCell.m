//
//  UserInfoCell.m
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kUserInfoCell_TitlePadding 2.f
#define kUserInfoCell_HeaderViewWidth 64.f
#define kUserInfoCell_NameLabelHeight 24.f
#define kUserInfoCell_CrownWidth 21.f
#define kUserInfoCell_CrownHeight 19.f
#define kUserInfoCell_GenderIconWidth 20.f
#define kUserInfoCell_LevelSize CGSizeMake(42.f, 16.f)
#define kUserInfoCell_NameFont [UIFont systemFontOfSize:16.f]
#define kUserInfoCell_LevelFont [UIFont systemFontOfSize:12.f]

#import "UserInfoCell.h"
#import "UITapImageView.h"
#import "MJPhotoBrowser.h"

@interface UserInfoCell ()
@property (strong, nonatomic) UITapImageView *userHeaderView;
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UILabel *userGenderLabel;
@property (strong, nonatomic) UILabel *userLevelLabel;
@property (strong, nonatomic) UIImageView *genderIconView;
@property (strong, nonatomic) UIImageView *crownView;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UILabel *thirdLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@end

@implementation UserInfoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_userHeaderView) {
            _userHeaderView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kUserInfoCell_HeaderViewWidth, kUserInfoCell_HeaderViewWidth)];
            @weakify(self);
            [_userHeaderView addTapBlock:^(id obj) {
                @strongify(self);
                [self handleTap];
            }];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_firstLabel) {
            _firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, kUserInfoCell_HeaderViewWidth/3)];
            _firstLabel.font = kUserInfoCell_NameFont;
            _firstLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_firstLabel];
        }
        if (!_genderIconView) {
            _genderIconView = [[UIImageView alloc] init];
            [self.contentView addSubview:_genderIconView];
        }
        if (!_userLevelLabel) {
            _userLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kUserInfoCell_LevelSize.width, kUserInfoCell_LevelSize.height)];
            _userLevelLabel.font = [UIFont boldSystemFontOfSize:13.f];
            _userLevelLabel.textAlignment = NSTextAlignmentCenter;
            _userLevelLabel.textColor = [UIColor whiteColor];
            _userLevelLabel.layer.cornerRadius = 2.f;
            _userLevelLabel.layer.masksToBounds = YES;
            [self.contentView addSubview:_userLevelLabel];
        }
        if (!_crownView) {
            _crownView = [[UIImageView alloc] init];
            _crownView.image = [UIImage imageNamed:@"crown"];
            [self.contentView addSubview:_crownView];
        }
        if (!_secondLabel) {
            _secondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _secondLabel.font = kUserInfoCell_LevelFont;
            _secondLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_secondLabel];
        }
        if (!_thirdLabel) {
            _thirdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _thirdLabel.font = kUserInfoCell_LevelFont;
            _thirdLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_thirdLabel];
        }
        if (!_distanceLabel) {
            _distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _distanceLabel.font = kUserInfoCell_LevelFont;
            _distanceLabel.textColor = SYSFONTCOLOR_GRAY;
            [self.contentView addSubview:_distanceLabel];
        }
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(kUserInfoCell_HeaderViewWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(_userHeaderView);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_equalTo(kUserInfoCell_HeaderViewWidth/3.f);
        }];
        [_genderIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_firstLabel.mas_right).offset(kUserInfoCell_TitlePadding);
            make.width.height.mas_equalTo(kUserInfoCell_GenderIconWidth);
            make.centerY.equalTo(_firstLabel);
        }];
        [_userLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_genderIconView.mas_right).offset(kUserInfoCell_TitlePadding);
            make.width.mas_equalTo(kUserInfoCell_LevelSize.width);
            make.height.mas_equalTo(kUserInfoCell_LevelSize.height);
            make.centerY.equalTo(_firstLabel);
        }];
        [_crownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userLevelLabel.mas_right).offset(kUserInfoCell_TitlePadding);
            make.bottom.equalTo(_userLevelLabel);
            make.width.mas_equalTo(kUserInfoCell_CrownWidth);
            make.height.mas_equalTo(kUserInfoCell_CrownHeight);
        }];
        [_secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_firstLabel.mas_bottom);
            make.left.equalTo(_firstLabel);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(kUserInfoCell_HeaderViewWidth/3.f);
        }];
        [_thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_secondLabel.mas_bottom);
            make.left.equalTo(_firstLabel);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(kUserInfoCell_HeaderViewWidth/3.f);
        }];
        [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_firstLabel.mas_bottom);
            make.left.equalTo(_firstLabel);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(kUserInfoCell_HeaderViewWidth/3.f);
        }];
    }
    return self;
}

- (void)setCurUser:(User *)curUser {
    _curUser = curUser;
    if (!_curUser) {
        return;
    }
    [_userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    
    //sex icon
    _genderIconView.image = [_curUser sexIcon];
    
    //level
    NSString *userrank = _curUser.userrank.stringValue;
    _crownView.hidden = ![[userrank substringFromIndex:userrank.length - 1] boolValue];
    [_userLevelLabel setText:[NSString stringWithFormat:@"LV.%@",[userrank substringToIndex:userrank.length - 1]]];
    _userLevelLabel.backgroundColor = [_curUser sexColor];
    
    //distance
    _distanceLabel.text = [NSString stringWithFormat:@"%@m 以内",@([_curUser distanceMeters])];
}

- (void)setCurContact:(Contact *)curContact {
    _curContact = curContact;
    [self clearAllInfo];
    //皇冠
    if (_curContact) { //如果存在好友关系
        _firstLabel.text = _curContact.contactmemo.length == 0?_curUser.username:_curContact.contactmemo; //第一行显示备注,如果没有备注就显示用户的昵称
        if (_curContact.contactmemo.length == 0) {  //如果没有备注
            if (_curUser.useruid && _curUser.useruid.length > 0)
                _secondLabel.text = [NSString stringWithFormat:@"帐号: %@",_curUser.useruid];
            else
                _secondLabel.text = nil;
        } else { //如果有备注
            if (!_curUser.useruid || [_curUser.useruid isEmpty]) {
                _secondLabel.text = [NSString stringWithFormat:@"昵称: %@",_curUser.username];
            } else {
                _secondLabel.text = [NSString stringWithFormat:@"帐号: %@",_curUser.useruid];
                _thirdLabel.text = [NSString stringWithFormat:@"昵称: %@",_curUser.username];
            }
        }
    } else { //如果不存在好友关系
        if (_curUser.username.length > 0) { //如果用户设置了昵称
            _firstLabel.text = _curUser.username;
            if (_curUser.useruid && _curUser.useruid.length > 0)
                _secondLabel.text = [NSString stringWithFormat:@"帐号: %@",_curUser.useruid];
            else
                _secondLabel.text = nil;
        } else { //如果用户没有设置昵称
            if (!_curUser.useruid || [_curUser.useruid isEmpty]) {
                _firstLabel.text = _curUser.usermobile;
            } else {
                _firstLabel.text = _curUser.useruid;
            }
        }
    }
}

- (void)clearAllInfo {
    _firstLabel.text = @"";
    _secondLabel.text = @"";
    _thirdLabel.text = @"";
}

- (void)setInfoType:(UserInfoType)infoType {
    _infoType = infoType;
    switch (_infoType) {
        case UserInfoTypeNormal: {
            //陌生人查看资料界面：头像右边，只能看到用户名，和后面的性别等级
            _distanceLabel.hidden = YES;
        }
            break;
        case UserInfoTypeAround: { //附近的人显示距离
            _distanceLabel.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)handleTap {
    NSMutableArray *photoArray = [NSMutableArray array];
    //头像
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.srcImageView = self.userHeaderView;
    photo.url = [NSURL imageURLWithString:_curUser.userlogourl];
    [photoArray addObject:photo];
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.showSaveBtn = NO;
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photoArray; // 设置所有的图片
    [browser show];
}

+ (CGFloat)cellHeight {
    return 88.f;
}
@end
