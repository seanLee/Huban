//
//  AroundUserCell.m
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAroundUserCell_HeaderWidth 48.f
#define kAroundUserCell_GenderIconWidth 20.f
#define kCharacterCell_CrownWidth 21.f
#define kCharacterCell_CrownHeight 19.f
#define kAroundUserCell_LevelSize CGSizeMake(42.f, 16.f)
#define kAroundUserCell_NameFont [UIFont systemFontOfSize:14.f]

#import "AroundUserCell.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface AroundUserCell ()
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UIImageView *sexIconView;
@property (strong, nonatomic) UIImageView *crownView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UILabel *distanceLabel;
@end

@implementation AroundUserCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _userNameLabel.font = kAroundUserCell_NameFont;
            _userNameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_sexIconView) {
            _sexIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
            _sexIconView.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:_sexIconView];
        }
        if (!_levelLabel) {
            _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAroundUserCell_LevelSize.width, kAroundUserCell_LevelSize.height)];
            _levelLabel.font = [UIFont boldSystemFontOfSize:13.f];
            _levelLabel.textAlignment = NSTextAlignmentCenter;
            _levelLabel.textColor = [UIColor whiteColor];
            _levelLabel.layer.cornerRadius = 2.f;
            _levelLabel.layer.masksToBounds = YES;
            [self.contentView addSubview:_levelLabel];
        }
        if (!_crownView) {
            _crownView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCharacterCell_CrownWidth, kCharacterCell_CrownHeight)];
            _crownView.image = [UIImage imageNamed:@"crown"];
            [self.contentView addSubview:_crownView];
        }
        if (!_distanceLabel) {
            _distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _distanceLabel.font = [UIFont systemFontOfSize:12.f];
            _distanceLabel.textColor = SYSFONTCOLOR_GRAY;
            [self.contentView addSubview:_distanceLabel];
        }
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kAroundUserCell_HeaderWidth);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(_userHeaderView);
        }];
        [_sexIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userNameLabel.mas_right).offset(0);
            make.centerY.equalTo(_userNameLabel);
            make.width.height.mas_equalTo(kAroundUserCell_GenderIconWidth);
        }];
        [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_sexIconView.mas_right).offset(2);
            make.centerY.equalTo(_userNameLabel);
            make.width.mas_equalTo(kAroundUserCell_LevelSize.width);
            make.height.mas_equalTo(kAroundUserCell_LevelSize.height);
        }];
        [_crownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_levelLabel.mas_right).offset(2);
            make.width.mas_equalTo(kCharacterCell_CrownWidth);
            make.height.mas_equalTo(kCharacterCell_CrownHeight);
            make.bottom.equalTo(_levelLabel);
        }];
        [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_userHeaderView);
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(kAroundUserCell_HeaderWidth/2);
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
    [_sexIconView setImage:[_curUser sexIcon]];
    [_levelLabel setBackgroundColor:[_curUser sexColor]];
    [_userNameLabel fitToText:_curUser.username];
    
    NSString *userrank = _curUser.userrank.stringValue;
    _crownView.hidden = ![[userrank substringFromIndex:userrank.length - 1] boolValue];
    [_levelLabel setText:[NSString stringWithFormat:@"LV.%@",[userrank substringToIndex:userrank.length - 1]]];
    
    CLLocationCoordinate2D curPoint = CLLocationCoordinate2DMake([Login curLoginUser].updatelat.doubleValue, [Login curLoginUser].updatelon.doubleValue);
    CLLocationCoordinate2D userPoint = CLLocationCoordinate2DMake(_curUser.updatelat.doubleValue, _curUser.updatelon.doubleValue);
    
    
    _distanceLabel.text = [self distanceStr:[[LocationManager shareInstance] getDistanceForPoint:curPoint andPoint:userPoint]];
}

- (NSString *)distanceStr:(int)distance {
    if (distance < 1000) {
        return @"1公里以内";
    } else if (distance >= 1000 && distance < 2000) {
        return @"2公里以内";
    } else if (distance >= 2000 && distance < 3000) {
        return @"3公里以内";
    } else if (distance >= 3000 && distance < 4000) {
        return @"4公里以内";
    } else if (distance >= 4000 && distance < 5000) {
        return @"5公里以内";
    } else if (distance >= 5000 && distance < 6000) {
        return @"6公里以内";
    } else if (distance >= 6000 && distance < 7000) {
        return @"7公里以内";
    } else if (distance >= 7000 && distance < 8000) {
        return @"8公里以内";
    } else if (distance >= 8000 && distance < 9000) {
        return @"9公里以内";
    } else if (distance >= 9000 && distance < 10000) {
        return @"10公里以内";
    }
    return @"10公里以外";
}

+ (CGFloat)cellHeight {
    return 66.f;
}
@end
