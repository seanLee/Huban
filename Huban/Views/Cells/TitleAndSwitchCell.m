//
//  TitleAndSwitchCell.m
//  Huban
//
//  Created by sean on 15/7/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTitleLabelWidth 150.f
#define kSwitchSize CGSizeMake(51.f, 31.f)

#import "TitleAndSwitchCell.h"

@interface TitleAndSwitchCell ()
@property (strong, nonatomic) UILabel *titleLbl;
@property (strong, nonatomic) UISwitch *settingSwitch;
@end

@implementation TitleAndSwitchCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_titleLbl) {
            _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth - kSwitchSize.width, [[self class] cellHeight])];
            _titleLbl.font = [UIFont systemFontOfSize:14.f];
            _titleLbl.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLbl];
        }
        if (!_settingSwitch) {
            _settingSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [_settingSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:_settingSwitch];
        }
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.width.mas_equalTo(kScreen_Width - 2*kPaddingLeftWidth - kSwitchSize.width);
        }];
        [_settingSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLbl.mas_right);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setSwitchSelected:(BOOL)switchSelected {
    _switchSelected = switchSelected;
    _settingSwitch.on = _switchSelected;
}

- (void)setCanSwitch:(BOOL)canSwitch {
    _canSwitch = canSwitch;
    _settingSwitch.enabled = _canSwitch;
}

- (void)setTitleStr:(NSString *)title {
    if (_titleLbl) {
        _titleLbl.text = title;
    }
}

+ (CGFloat)cellHeight {
    return 44.f;
}

#pragma mark - Action
- (void)switchAction:(UISwitch *)sender {
    if (_haveSwitchSettingBlock) {
        _haveSwitchSettingBlock(sender.on);
    }
}
@end
