//
//  Message_RootViewController.m
//  Huban
//
//  Created by sean on 15/11/22.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Message_RootViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface Message_RootViewController () <EaseConversationListViewControllerDataSource, EaseConversationListViewControllerDelegate>
@property (strong, nonatomic) User *loginUser;
@end

@implementation Message_RootViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //读取所有本地对话
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    
    self.title = @"呼伴";
    
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    //获取当前登录用户的信息
    self.loginUser = [Login curLoginUser];
    //如果用户已经登录,激活app刷新当前坐标
    [self refreshUserLocation];
    
    [self removeEmptyConversationsFromDB];
}

- (void)refreshUserLocation
{
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        self.loginUser.updatelat = [NSNumber numberWithDouble:userLocation.location.coordinate.latitude];
        self.loginUser.updatelon = [NSNumber numberWithDouble:userLocation.location.coordinate.longitude];
        [[NetAPIManager shareManager] request_updateLocationWithParams:self.loginUser andBlock:^(id data, NSError *error) {
            //do nothing
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

#pragma mark - EMChatManagerDelegate
- (void)tableViewDidTriggerHeaderRefresh {
    [super tableViewDidTriggerHeaderRefresh];
    [self refreUI]; //刷新未读消息
}

- (void)refreUI {
    NSInteger badgeValue =  [self numberOfUnreadCommentNotification];
    //未读取的消息
    badgeValue += [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    //刷新底部tabbar的数字
    RDVTabBarController *baseVC = (RDVTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController; //获取window
    RDVTabBarItem *barItem = [baseVC.tabBar items].firstObject;
    if (badgeValue == 0) { //如果为0,就不显示
        barItem.badgeValue = @"";
    } else {
        barItem.badgeValue = [NSString stringWithFormat:@"%@",@(badgeValue)];
    }
}

@end
