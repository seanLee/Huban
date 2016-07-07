//
//  NewTweetViewController.h
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger,SendTopicType) {
    SendTopicType_ToCityCircle = 0,
    SendTopicType_ToFriendCircle,
    SendTopicType_ToAlbum
};

#import "BaseViewController.h"

@interface SendTweetViewController : BaseViewController
@property (strong, nonatomic) Topic *sendedTopic;
@property (strong, nonatomic) Region *curRegion;
@property (assign, nonatomic) SendTopicType topicType;

@property (assign, nonatomic) BOOL fromAlbum;

@property (copy, nonatomic) void (^refreshBlock)();
@end
