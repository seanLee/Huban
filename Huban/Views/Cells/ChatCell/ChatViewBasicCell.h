//
//  ChatViewBasicCell.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kChatViewBasicCell_HeaderWidth 40.f     //头像的长宽
#define NAME_LABEL_WIDTH 180                    // nameLabel最大宽度
#define NAME_LABEL_HEIGHT 15                    // nameLabel 高度
#define NAME_LABEL_PADDING 5                    // nameLabel间距
#define NAME_LABEL_FONT_SIZE 14                 // 字体

#import <UIKit/UIKit.h>
#import "ChatBaseBubbleView.h"
#import "UIResponder+Router.h"
#import "EMMessage.h"

@interface ChatViewBasicCell : UITableViewCell
@property (strong, nonatomic) EaseMessageModel *curMessage;

@property (strong, nonatomic) UITapImageView *userIconView;             //头像
@property (strong, nonatomic) ChatBaseBubbleView *bubbleView;           //姓名
@property (strong, nonatomic) UILabel *nameLabel;                       //内容区域

@property (copy, nonatomic) void (^userHeaderTapBlock)(User *);

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier andMessage:(EaseMessageModel *)message;

- (void)setupSubviewsWithObj:(EaseMessageModel *)message;

+ (NSString *)cellIdentifierForMessage:(MessageBodyType)messageType;
+ (CGFloat)cellHeightWithObj:(EaseMessageModel *)message;
@end
