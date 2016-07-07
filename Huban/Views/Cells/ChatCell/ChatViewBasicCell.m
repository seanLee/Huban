//
//  ChatViewBasicCell.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ChatViewBasicCell.h"

@interface ChatViewBasicCell ()
@property (strong, nonatomic) User *toUser;
@end

@implementation ChatViewBasicCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier andMessage:(EaseMessageModel *)message {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UITapImageView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:_userIconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _nameLabel.font = kBaseFont;
            _nameLabel.textColor = [UIColor colorWithHexString:@"0x888888"];
            [self.contentView addSubview:_nameLabel];
        }
        [self setupSubviewsWithObj:message];
        
        @weakify(self);
        //监听user
        [RACObserve(self, toUser) subscribeNext:^(User *user) {
            @strongify(self);
            if (user) {
                self.nameLabel.text = self.toUser.username.length == 0?self.toUser.useruid:self.toUser.username;
                [self.userIconView sd_setImageWithURL:[NSURL thumbImageURLWithString:self.toUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
            }
        }];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    //relocate the subviews
    
    CGRect frame = _userIconView.frame;
    frame.origin.x = [_curMessage isSender]?(self.bounds.size.width - _userIconView.frame.size.width - kPaddingLeftWidth) : kPaddingLeftWidth;
    _userIconView.frame = frame;
    
    [_nameLabel sizeToFit];
    frame = _nameLabel.frame;
    frame.origin.x = kPaddingLeftWidth * 2 + CGRectGetWidth(_userIconView.frame) + NAME_LABEL_PADDING;
    frame.origin.y = CGRectGetMinY(_userIconView.frame);
    frame.size.width = NAME_LABEL_WIDTH;
    _nameLabel.frame = frame;
}

- (void)setCurMessage:(EaseMessageModel *)curMessage {
    _curMessage = curMessage;
    if (!_curMessage) {
        return;
    }
    _nameLabel.hidden = (_curMessage.messageType == eMessageTypeChat);
    if (_curMessage.isSender) { //如果是自己发送消息
        _toUser = [Login curLoginUser];
        [_userIconView sd_setImageWithURL:[NSURL thumbImageURLWithString:_toUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    } else {
        self.toUser = [[DataBaseManager shareInstance] userByUserCode:_curMessage.message.from]; //从本地获取数据
        if (!self.toUser) { //如果本地不存在数据,就从服务器上获取用户信息,并保存在本地
            @weakify(self);
            [[NetAPIManager shareManager] request_get_userWithUsercode:_curMessage.message.from andBlock:^(id data, NSError *error) {
                @strongify(self);
                if (data) {
                    self.toUser = [NSObject objectOfClass:@"User" fromJSON:data];
                    [[DataBaseManager shareInstance] saveUser:self.toUser]; //保存到本地数据库
                }
            }];
        }
    }
}

- (void)setUserHeaderTapBlock:(void (^)(User *))userHeaderTapBlock {
    __weak typeof(self) weakSelf = self;
    _userHeaderTapBlock = userHeaderTapBlock;
    [_userIconView addTapBlock:^(id obj) {
        if (weakSelf.toUser) {
            weakSelf.userHeaderTapBlock(weakSelf.toUser);
        }
    }];
}

- (void)setupSubviewsWithObj:(EaseMessageModel *)message {
    CGRect frame;
    if (message.isSender) {
        frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - kChatViewBasicCell_HeaderWidth, 0, kChatViewBasicCell_HeaderWidth, kChatViewBasicCell_HeaderWidth);
    } else {
        frame = CGRectMake(kPaddingLeftWidth, 0, kChatViewBasicCell_HeaderWidth, kChatViewBasicCell_HeaderWidth);
    }
    [_userIconView setFrame:frame];
}

+ (NSString *)cellIdentifierForMessage:(MessageBodyType)messageType {
    NSString *identifier = @"ChatViewCell";
    switch (messageType) {
        case eMessageBodyType_Text: {
            identifier = [identifier stringByAppendingString:@"_text"];
        }
            break;
        case eMessageBodyType_Image: {
            identifier = [identifier stringByAppendingString:@"_image"];
        }
            break;
        case eMessageBodyType_Voice: {
            identifier = [identifier stringByAppendingString:@"_voice"];
        }
            break;
        case eMessageBodyType_Video: {
            identifier = [identifier stringByAppendingString:@"_video"];
        }
            break;
        case eMessageBodyType_Location: {
            identifier = [identifier stringByAppendingString:@"_location"];
        }
            break;
        default:
            break;
    }
    return identifier;
}

#pragma mark - Public
+ (CGFloat)cellHeightWithObj:(EMMessage *)message {
    return kChatViewBasicCell_HeaderWidth;
}
@end
