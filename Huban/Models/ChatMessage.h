//
//  ChatMessage.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, ChatMessageGrouType) {
    ChatMessageGrouTypeChat,
    ChatMessageGrouTypeGroup
};

typedef NS_ENUM(NSInteger, ChatMessageType) {
    ChatMessageType_Text = 0,
    ChatMessageType_Image,
    ChatMessageType_Video,
    ChatMessageType_Location,
    ChatMessageType_Voice
};

typedef NS_ENUM(NSInteger, ChatMessageSendState) {
    ChatMessageSendStateSuccess = 0,
    ChatMessageSendStateSending,
    ChatMessageSendStateFail
};

#import <Foundation/Foundation.h>
#import "VoiceMedia.h"

@interface ChatMessage : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *extra, *file;
@property (readwrite, nonatomic, strong) User *friend, *sender;
@property (readwrite, nonatomic ,assign) BOOL isSender;
@property (readwrite, nonatomic, strong) NSNumber *count, *unreadCount, *id, *read_at, *status, *duration, *played, *playing;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (assign, nonatomic) ChatMessageType messageType;          //消息类型
@property (assign, nonatomic) ChatMessageSendState sendStatus;      //消息状态
@property (assign, nonatomic) ChatMessageGrouType groupType;        //是否是群发消息
@property (strong, nonatomic) VoiceMedia *voiceMedia;               //语音消息
@property (strong, nonatomic) NSString *imageMediaStr;              //图片链接

- (BOOL)hasMedia;

+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend;

- (NSString *)toSendPath;
- (NSDictionary *)toSendParams;

- (NSString *)toDeletePath;
@end
