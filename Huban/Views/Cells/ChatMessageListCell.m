//
//  ChatMessageListCell.m
//  Huban
//
//  Created by sean on 15/7/27.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellMargin_Left 8.f
#define kHeaderView_Width 48.f
#define kTimeLabel_Width 20.f

#import "ChatMessageListCell.h"
#import "EaseConversationModel.h"

@interface ChatMessageListCell ()
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *messageInfoLabel;

@property (strong, nonatomic) NSString *userCode;
@end

@implementation ChatMessageListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeaderView_Width, kHeaderView_Width)];
            _userHeaderView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_userHeaderView.frame) + kCellMargin_Left, CGRectGetMinY(_userHeaderView.frame), 100.f, kHeaderView_Width / 2.f)];
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
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kTimeLabel_Width - kCellMargin_Left, CGRectGetMinY(_userHeaderView.frame), kTimeLabel_Width, kTimeLabel_Width)];
            _timeLabel.font = [UIFont systemFontOfSize:12.f];
            _timeLabel.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_timeLabel];
        }
       [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(kCellMargin_Left);
           make.width.height.mas_equalTo(kHeaderView_Width);
           make.centerY.equalTo(self.contentView.mas_centerY);
       }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kCellMargin_Left);
            make.top.equalTo(_userHeaderView);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        [_messageInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userNameLabel.mas_left);
            make.bottom.equalTo(_userHeaderView);
            make.height.mas_equalTo(kHeaderView_Width / 2.f);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeftWidth);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-kCellMargin_Left);
            make.top.equalTo(self.contentView).offset(kCellMargin_Left);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        
        @weakify(self);
        //监控两个对象
        [RACObserve(self, curContact) subscribeNext:^(Contact *relation) {
            @strongify(self);
            if (relation) {
                self.userNameLabel.text = [self.curContact.contactmemo isEmpty]?self.curContact.contactname:self.curContact.contactmemo;
                [self.userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:relation.contactlogourl] placeholderImage:[UIImage avatarPlacer]];
            }
        }];
    }
    return self;
}

- (void)setConversation:(EaseConversationModel *)conversation {
    _conversation = conversation;
    if (!_conversation) {
        return;
    }
    self.userCode = _conversation.conversation.chatter;
    //时间
    EMMessage *lastMessage = [_conversation.conversation latestMessage];
    id<IMessageModel> model = [[EaseMessageModel alloc] initWithMessage:lastMessage];
    NSDate *lastMessageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:lastMessage.timestamp];
    _timeLabel.text = [lastMessageDate formattedTime];
    
    //是否置顶
    NSDictionary *ext = [_conversation.conversation ext];
    if (ext) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    
    switch (model.bodyType) {
        case eMessageBodyType_Text: {
            _messageInfoLabel.text = model.text;
        }
            break;
        case eMessageBodyType_Image: {
            _messageInfoLabel.text = @"[图片]";
        }
            break;
        case eMessageBodyType_Voice: {
            _messageInfoLabel.text = @"[语音]";
        }
            break;
        case eMessageBodyType_Location: {
            _messageInfoLabel.text = @"[位置]";
        }
            break;
        default:
            break;
    }
    //查询本地用户关系
    Contact *localContact = [[DataBaseManager shareInstance] relationForUser:self.userCode];
    self.curContact = localContact;
    @weakify(self);
    //从服务器查询数据库
    [[NetAPIManager shareManager] request_get_contactWithParams:self.userCode andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) { //如果查询到contact
            self.curContact = [NSObject objectOfClass:@"Contact" fromJSON:data];
            //刷新数据
            if (localContact) { //如果本地存在数据,更新数据
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[DataBaseManager shareInstance] deleteContact:localContact];
                });
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DataBaseManager shareInstance] saveContact:self.curContact];
            });
        }
    }];
    
    CGPoint center;
    //unread count
    NSInteger unreadCount = [_conversation.conversation unreadMessagesCount];
    if (unreadCount > 99) {
        center = CGPointMake(kPaddingLeftWidth + kHeaderView_Width - 10.f, 12.f);
    } else {
        center = CGPointMake(kPaddingLeftWidth + kHeaderView_Width - 4.f, 12.f);
    }
    [self.contentView addBadgeTip:[NSString stringWithFormat:@"%@",@(unreadCount)] withCenterPosition:center];

    if (unreadCount == 0) { //如果没有未读信息,取消提示
        [self.contentView removeBadgeTips];
    }
}

+ (CGFloat)cellHeight {
    return 66.f;
}

@end
