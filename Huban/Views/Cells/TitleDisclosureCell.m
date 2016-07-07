//
//  TitleDisclosureCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TitleDisclosureCell.h"

@interface TitleDisclosureCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSString *title;
@end

@implementation TitleDisclosureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, (kScreen_Width - 120), 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:14.f];
            _titleLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLabel];
        }
    }
    return self;
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    if (_showIndicator) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLabel.text = _title;
}

- (void)setTitleStr:(NSString *)title{
    self.title = title;
}

+ (CGFloat)cellHeight {
    return 44.f;
}

@end
