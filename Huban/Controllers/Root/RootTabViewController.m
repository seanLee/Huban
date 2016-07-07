//
//  RootTabViewController.m
//  Huban
//
//  Created by sean on 15/7/25.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "RootTabViewController.h"
#import "RDVTabBarItem.h"
#import "BaseNavigationController.h"
#import "CityCircle_RootViewController.h"
#import "Message_RootViewController.h"
#import "Contact_RootViewController.h"
#import "Discover_RootViewController.h"
#import "Me_RootViewController.h"
#import "EMCDDeviceManager+Remind.h"

static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface RootTabViewController () <EMChatManagerDelegate>
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation RootTabViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
    
    //把self注册为环信的delegate
    [self registerNotifications];
}
#pragma mark - Private Method
- (void)setupViewControllers {
    
    CityCircle_RootViewController *cityCircleVC = [[CityCircle_RootViewController alloc] init];
    BaseNavigationController *nav_cityCircle = [[BaseNavigationController alloc] initWithRootViewController:cityCircleVC];
    
    Message_RootViewController *messageVC = [[Message_RootViewController alloc] init];
    BaseNavigationController *nav_message = [[BaseNavigationController alloc] initWithRootViewController:messageVC];
    
    Contact_RootViewController *contactVC = [[Contact_RootViewController alloc] init];
    BaseNavigationController *nav_contact = [[BaseNavigationController alloc] initWithRootViewController:contactVC];
    
    Discover_RootViewController *discoverVC = [[Discover_RootViewController alloc] init];
    BaseNavigationController *nav_discover = [[BaseNavigationController alloc] initWithRootViewController:discoverVC];
    
    Me_RootViewController *meVC = [[Me_RootViewController alloc] init];
    BaseNavigationController *nav_me = [[BaseNavigationController alloc] initWithRootViewController:meVC];
    
    [self setViewControllers:@[nav_message, nav_contact, nav_discover, nav_cityCircle ,nav_me]];
    
    [self customizeTabBarForController];
    self.delegate = self;
}

- (void)customizeTabBarForController {
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    NSArray *tabBarItemImages = @[@"tabbar_message",@"tabbar_contact",@"tabbar_find",@"tabbar_city",@"tabbar_me"];
    NSArray *tabBarItemTitles = @[@"呼伴",@"通讯录",@"发现",@"同城",@"我的"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *curItem in self.tabBar.items) {
        curItem.titlePositionAdjustment = UIOffsetMake(0, 2.f);
        [curItem setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_pressed",[tabBarItemImages objectAtIndex:index]]];
        UIImage *normalImage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [curItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:normalImage];
        [curItem setTitle:[tabBarItemTitles objectAtIndex:index]];
        index++;
    }
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedViewController != viewController) {
        return YES;
    }
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.topViewController != nav.viewControllers[0]) {
        return YES;
    }
    BaseViewController *rootVc = (BaseViewController *)nav.topViewController;
    [rootVc tabBarItemClicked];
    return YES;
}

#pragma - EMChatManagerDelegate
- (void)didUnreadMessagesCountChanged {
    Message_RootViewController *vc = (Message_RootViewController *)[UIViewController message_rootVC];
    if ([vc isKindOfClass:[Message_RootViewController class]] && [vc respondsToSelector:@selector(tableViewDidTriggerHeaderRefresh)]) {
        [vc tableViewDidTriggerHeaderRefresh];
    }
}

- (void)didReceiveMessage:(EMMessage *)message {
    BOOL needShowNotification = (message.messageType != eMessageTypeChat) ? [self needShowNotification:message.conversationChatter] : YES;
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:message.conversationChatter conversationType:eConversationTypeChat];
    if (needShowNotification) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
            case UIApplicationStateActive:
                if (conversation.enableUnreadMessagesCountEvent) {
                    [self playSoundAndVibration];
                }
                break;
            case UIApplicationStateInactive:
                if (conversation.enableUnreadMessagesCountEvent) {
                    [self playSoundAndVibration];
                }
                break;
            case UIApplicationStateBackground:
                [self showNotificationWithMessage:message];
                break;
            default:
                break;
        }
    }
}

#pragma mark - private
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (BOOL)needShowNotification:(NSString *)fromChatter{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (void)showNotificationWithMessage:(EMMessage *)message {
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        NSLog(@"全部");
    }
}
@end
