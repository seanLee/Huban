//
//  TranspondCell.m
//  Huban
//
//  Created by sean on 15/12/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kTranspondCell_HeaderWidth 48.f
#define kTranspondCell_CheckWidth 24.f

#import "TranspondCell.h"
#import "UITapImageView.h"

@interface TranspondCell ()
@property (strong, nonatomic) UITapImageView *headerImageView;
@property (strong, nonatomic) UILabel *contactLabel;
@property (strong, nonatomic) UIImageView *checkImageV;
@end

@implementation TranspondCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        if (!_headerImageView) {
            _headerImageView = [[UITapImageView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:_headerImageView];
        }
        if (!_contactLabel) {
            _contactLabel = [[UILabel alloc] init];
            _contactLabel.font = [UIFont systemFontOfSize:14.f];
            [self.contentView addSubview:_contactLabel];
        }
        if (!_checkImageV) {
            _checkImageV = [[UIImageView alloc] init];
            _checkImageV.image = [UIImage imageNamed:@"checkmark_Box"];
            [self.contentView addSubview:_checkImageV];
        }
        [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kTranspondCell_HeaderWidth);
        }];
        [_contactLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_headerImageView.mas_right).offset(kPaddingLeftWidth);
            make.right.mas_equalTo(_checkImageV.mas_left).offset(-kPaddingLeftWidth);
            make.top.bottom.equalTo(self.contentView);
        }];
        [_checkImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.height.mas_equalTo(kTranspondCell_CheckWidth);
        }];
    }
    return self;
}

- (void)setCurContact:(Contact *)curContact {
    _curContact = curContact;
    if (!_curContact) {
        return;
    }
    _contactLabel.text = _curContact.contactname;
    [_headerImageView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curContact.contactlogourl] placeholderImage:[UIImage avatarPlacer]];
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    _checkImageV.image = [UIImage imageNamed:_checked?@"checkmark":@"checkmark_Box"];
}

+ (CGFloat)cellHeight {
    return 66.f;
}
@end
