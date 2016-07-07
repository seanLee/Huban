//
//  ChatMessage.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendStatus = ChatMessageSendStateSuccess;
        _id = @(-1);
    }
    return self;
}

- (NSString *)content {
    if (_content) {
        return _content;
    } else {
        return @"";
    }
}

- (BOOL)hasMedia{
    return YES;
}

+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend{
    ChatMessage *nextMsg = [[ChatMessage alloc] init];
    nextMsg.sender = [Login curLoginUser];
    nextMsg.friend = curFriend;
    nextMsg.sendStatus = ChatMessageSendStateSending;
    nextMsg.created_at = [NSDate date];
    
    return nextMsg;
};

- (NSString *)toSendPath{
    return @"";
}
- (NSDictionary *)toSendParams{
    return @{};
}


- (NSString *)toDeletePath{
    return @"";
}
@end
