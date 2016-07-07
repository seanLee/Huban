//
//  NotificationCell.m
//  Huban
//
//  Created by sean on 15/9/21.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kNotificationCell_ImageWidth 36.f
#define kNotificationCell_ContentWidth (kScreen_Width - kNotificationCell_ImageWidth - 3*kPaddingLeftWidth)
#define kNotificationCell_ContentFont [UIFont systemFontOfSize:12.f]

#import "NotificationCell.h"

@interface NotificationCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation NotificationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kNotificationCell_ImageWidth, kNotificationCell_ImageWidth)];
            [self.contentView addSubview:_userIconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _nameLabel.font = [UIFont systemFontOfSize:13.f];
            _nameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_nameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _timeLabel.font = [UIFont systemFontOfSize:12.f];
            _timeLabel.textColor = SYSFONTCOLOR_GRAY;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _contentLabel.font = kNotificationCell_ContentFont;
            _contentLabel.numberOfLines = 0;
            _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
            _contentLabel.textColor = SYSFONTCOLOR_GRAY;
            [self.contentView addSubview:_contentLabel];
        }
        [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(4); // (44.f - 36.f)/2
            make.width.height.mas_equalTo(kNotificationCell_ImageWidth);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userIconView);
            make.left.equalTo(_userIconView.mas_right).offset(kPaddingLeftWidth);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userIconView);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.width.height.mas_greaterThanOrEqualTo(0);
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userIconView.mas_centerY);
            make.left.equalTo(_userIconView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
    }
    return self;
}

- (void)setCurComment:(TopicComment *)curComment {
    _curComment = curComment;
    if (!_curComment) {
        return;
    }
}

//- (void)setCurComment:(Comment *)curComment {
//    _curComment = curComment;
//    if (!_curComment) {
//        return;
//    }
//    [_userIconView sd_setImageWithURL:[NSURL URLWithString:_curComment.owner.userlogourl] placeholderImage:[UIImage avatarPlacerWithGender:_curComment.owner.usersex]];
//    _nameLabel.text = _curComment.owner.username;
//    _timeLabel.text = [NSString stringWithFormat:@"%@",[_curComment.created_at stringWithFormat:@"MM/dd HH:mm"]];
//    _contentLabel.text = _curComment.content;
//}

+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[TopicComment class]]) {
        TopicComment *curComment = (TopicComment *)obj;
        
        cellHeight += 4; //(44.f - 36.f)/2
        cellHeight += kNotificationCell_ImageWidth / 2;
        
        CGFloat contentHeight = [curComment.commentcontent getHeightWithFont:kNotificationCell_ContentFont constrainedToSize:CGSizeMake(kNotificationCell_ContentWidth, CGFLOAT_MAX)];
        cellHeight += contentHeight;
        
        cellHeight += 4; //(44.f - 36.f)/2
    }
    return cellHeight;
}
@end
