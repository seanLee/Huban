//
//  TitleRImageMoreCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTitleRImageMoreCell_HeightIcon 48.f
#define kTitleRImageMoreCell_LabelWidth 80.f

#import "TitleRImageMoreCell.h"
#import "MJPhotoBrowser.h"

@interface TitleRImageMoreCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *userIconView;
@end
@implementation TitleRImageMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 80.f, 30)];
            _titleLabel.font = [UIFont systemFontOfSize:14.f];
            _titleLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width- kTitleRImageMoreCell_HeightIcon)- kPaddingLeftWidth- 30, ([TitleRImageMoreCell cellHeight] -kTitleRImageMoreCell_HeightIcon)/2, kTitleRImageMoreCell_HeightIcon, kTitleRImageMoreCell_HeightIcon)];
            _userIconView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [_userIconView addGestureRecognizer:tap];
            [self.contentView addSubview:_userIconView];
        }
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kTitleRImageMoreCell_LabelWidth);
            make.height.mas_equalTo([[self class] cellHeight]);
        }];
        [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kTitleRImageMoreCell_HeightIcon);
        }];
    }
    return self;
}

- (void)setTitleStr:(NSString *)title {
    if (title) {
        _titleLabel.text = title;
    }
}

- (void)setCurUser:(User *)curUser {
    _curUser = curUser;
    if (!_curUser) {
        return;
    }
    [_userIconView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
}

+ (CGFloat)cellHeight{
    return 66.f;
}

#pragma mark - Action
- (void)handleTap:(id)sender {
    //1.拿到头像
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.srcImageView = _userIconView;
    photo.url = [NSURL imageURLWithString:_curUser.userlogourl];
    NSArray *photos = [NSArray arrayWithObject:photo];
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.showSaveBtn = NO;
    browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}
@end
