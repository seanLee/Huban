//
//  ChatMessageListCell.h
//  Huban
//
//  Created by sean on 15/7/27.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_ChatMessageListCell @"ChatMessageListCell"
@class EaseConversationModel;

#import "SWTableViewCell.h"

@interface ChatMessageListCell : SWTableViewCell
@property (strong, nonatomic) EaseConversationModel *conversation;
@property (strong, nonatomic) Contact *curContact;
+ (CGFloat)cellHeight;
@end
