//
//  EaseConversationListViewController.h
//  Huban
//
//  Created by sean on 15/11/22.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "EaseRefreshTableViewController.h"

#import "EaseConversationModel.h"

typedef NS_ENUM(int, DXDeleteConvesationType) {
    DXDeleteConvesationOnly,
    DXDeleteConvesationWithMessages,
};

@class EaseConversationListViewController;

@protocol EaseConversationListViewControllerDelegate <NSObject>

@optional

- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
            didSelectConversationModel:(id<IConversationModel>)conversationModel;

@end

@protocol EaseConversationListViewControllerDataSource <NSObject>

@optional

- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
                                    modelForConversation:(EMConversation *)conversation;


- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
      latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel;

- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
       latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel;

@end

@interface EaseConversationListViewController : EaseRefreshTableViewController
@property (weak, nonatomic) id<EaseConversationListViewControllerDelegate> delegate;
@property (weak, nonatomic) id<EaseConversationListViewControllerDataSource> dataSource;

- (void)tableViewDidTriggerHeaderRefresh;
//评论通知的未读取量
- (NSInteger)numberOfUnreadCommentNotification;
@end
