//
//  ToMessageCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellMargin_Left 8.f
#define kHeaderView_Width 48.f
#define kTimeLabel_Width 20.f

#import "ToMessageCell.h"
#import "CommentNotification.h"

@interface ToMessageCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *messageInfoLabel;
@end

@implementation ToMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeaderView_Width, kHeaderView_Width)];
            _iconView.backgroundColor = [UIColor blackColor];
            [self.contentView addSubview:_iconView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconView.frame) + kCellMargin_Left, CGRectGetMinY(_iconView.frame), 100.f, kHeaderView_Width / 2.f)];
            _userNameLabel.font = [UIFont systemFontOfSize:15.f];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_messageInfoLabel) {
            _messageInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_userNameLabel.frame), CGRectGetMaxY(_userNameLabel.frame), 200.f, kHeaderView_Width / 2.f)];
            _messageInfoLabel.font = [UIFont systemFontOfSize:12.f];
            _messageInfoLabel.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_messageInfoLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kTimeLabel_Width - kCellMargin_Left, CGRectGetMinY(_iconView.frame), kTimeLabel_Width, kTimeLabel_Width)];
            _timeLabel.font = [UIFont systemFontOfSize:12.f];
            [self.contentView addSubview:_timeLabel];
        }
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kCellMargin_Left);
            make.width.height.mas_equalTo(kHeaderView_Width);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(kCellMargin_Left);
            make.top.equalTo(_iconView);
        }];
        [_messageInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userNameLabel.mas_left);
            make.bottom.equalTo(_iconView);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kCellMargin_Left);
            make.top.equalTo(self.contentView).offset(kCellMargin_Left);
        }];
    }
    return self;
}

- (void)setType:(ToMessageType)type{
    _type = type;
    NSString *imageName, *titleStr;
    switch (_type) {
        case ToMessageTypeAT:
            imageName = @"messageAT";
            titleStr = @"@我的";
            break;
        case ToMessageTypeComment:
            imageName = @"messageComment";
            titleStr = @"评论通知";
            break;
        case ToMessageTypeSystemNotification:
            imageName = @"messageSystem";
            titleStr = @"系统消息";
            break;
        default:
            break;
    }
    _iconView.image = [UIImage imageNamed:imageName];
    _userNameLabel.text = titleStr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(kPaddingLeftWidth, ([ToMessageCell cellHeight]-48)/2, 48, 48);
    self.textLabel.frame = CGRectMake(75, ([ToMessageCell cellHeight]-30)/2, (kScreen_Width - 120), 30);
    NSString *badgeTip = @"";
    if (_unreadCount && _unreadCount.integerValue > 0) {
        if (_unreadCount.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _unreadCount.stringValue;
        }
        self.accessoryType = UITableViewCellAccessoryNone;
    }else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGPoint center;
    if (_unreadCount.integerValue > 99) {
        center = CGPointMake(kPaddingLeftWidth + kHeaderView_Width - 10.f, 12.f);
    } else {
        center = CGPointMake(kPaddingLeftWidth + kHeaderView_Width - 4.f, 12.f);
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:center];
    
    switch (_type) {
        case ToMessageTypeComment: {
            //获取最后一条评论通知
            CommentNotification *notification = [[DataBaseManager shareInstance] lastCommentNotification];
            if (notification) {
                _messageInfoLabel.text = notification.noticontent;
            }
        }
            break;
            
        default:
            break;
    }
}

+ (CGFloat)cellHeight{
    return 66.f;
}

@end
