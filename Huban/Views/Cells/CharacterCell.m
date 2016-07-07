//
//  CharacterCell.m
//  Huban
//
//  Created by sean on 15/8/5.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCharacterCell_HeaderWidth 48.f
#define kCharacterCell_CrownWidth 21.f
#define kCharacterCell_CrownHeight 19.f
#define kCharacterCell_PaddingLeft 6.f
#define kCharacterCell_MarginTop 18.f
#define kCharacterCell_LevelSize CGSizeMake(42.f, 16.f)
#define kCharacterCell_ExpFont [UIFont systemFontOfSize:13.f]

#import "CharacterCell.h"

@interface CharacterCell ()
@property (strong, nonatomic) UIImageView *headerView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UILabel *expLabel;
@property (strong, nonatomic) UIImageView *crownIconView;
@end

@implementation CharacterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_headerView) {
            _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kCharacterCell_HeaderWidth, kCharacterCell_HeaderWidth)];
            [self.contentView addSubview:_headerView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _userNameLabel.font = [UIFont boldSystemFontOfSize:13.f];
            _userNameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_levelLabel) {
            _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kCharacterCell_LevelSize.width, kCharacterCell_LevelSize.height)];
            _levelLabel.font = [UIFont boldSystemFontOfSize:13.f];
            _levelLabel.textAlignment = NSTextAlignmentCenter;
            _levelLabel.textColor = [UIColor whiteColor];
            _levelLabel.layer.cornerRadius = 2.f;
            _levelLabel.layer.masksToBounds = YES;
            [self.contentView addSubview:_levelLabel];
        }
        if (!_crownIconView) {
            _crownIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCharacterCell_CrownWidth, kCharacterCell_CrownHeight)];
            _crownIconView.image = [UIImage imageNamed:@"crown"];
            [self.contentView addSubview:_crownIconView];
        }
        if (!_expLabel) {
            _expLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, [[self class] cellHeight])];
            _expLabel.font = kBaseFont;
            _expLabel.textColor = SYSFONTCOLOR_GRAY;
            [self.contentView addSubview:_expLabel];
        }
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.height.width.mas_equalTo(kCharacterCell_HeaderWidth);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headerView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kCharacterCell_MarginTop);
        }];
        [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userNameLabel.mas_right).offset(2);
            make.top.equalTo(_userNameLabel);
            make.width.mas_equalTo(kCharacterCell_LevelSize.width);
            make.height.mas_equalTo(kCharacterCell_LevelSize.height);
        }];
        [_expLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userNameLabel);
            make.top.equalTo(_userNameLabel.mas_bottom).offset(4);
        }];
        [_crownIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_levelLabel.mas_right).offset(2);
            make.width.mas_equalTo(kCharacterCell_CrownWidth);
            make.height.mas_equalTo(kCharacterCell_CrownHeight);
            make.bottom.equalTo(_levelLabel);
        }];
    }
    return self;
}

- (void)setCurUser:(User *)curUser {
    _curUser = curUser;
    if (!_curUser) {
        return;
    }
    [_headerView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    [_expLabel fitToText:[NSString stringWithFormat:@"%@/500",_curUser.usercredit.stringValue]];
    [_userNameLabel fitToText:@"我的人品"];
    _levelLabel.backgroundColor = [_curUser sexColor];
    
     NSString *userrank = _curUser.userrank.stringValue;
    _crownIconView.hidden = ![[userrank substringFromIndex:userrank.length - 1] boolValue];
    [_levelLabel setText:[NSString stringWithFormat:@"LV.%@",[userrank substringToIndex:userrank.length - 1]]];
}

+ (CGFloat)cellHeight {
    return 66.f;
}
@end
