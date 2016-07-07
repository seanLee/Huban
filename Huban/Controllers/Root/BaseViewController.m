//
//  BaseViewController.m
//  Huban
//
//  Created by sean on 15/7/25.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseNavigationController.h"
#import "RootTabViewController.h"
#import "AppDelegate.h"
#import "CommentNotification.h"
#import "Message_RootViewController.h"
#import "Contact_RootViewController.h"

typedef NS_ENUM(NSInteger, AnalyseMethodType) {
    AnalyseMethodTypeRefresh = 0,
    AnalyseMethodTypeLazyCreate,
    AnalyseMethodTypeForceCreate
};

@interface BaseViewController () <EMChatManagerDelegate>

@end

@implementation BaseViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //如果需要统计,添加统计信息
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //如果需要统计,添加统计信息
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
}

- (void)loadView {
    [super loadView];
    if (self.interfaceOrientation != UIInterfaceOrientationPortrait
        && !([self supportedInterfaceOrientations] & UIInterfaceOrientationMaskLandscapeLeft)) {
        [self forceChangeToOrientation:UIInterfaceOrientationPortrait];
    }
}

- (void)tabBarItemClicked {
    DebugLog(@"\ntabBarItemClicked:%@",NSStringFromClass([self class]));
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate {
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

#pragma mark - Private Method
+ (void)handleNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState {
    NSInteger msgType = [userInfo[@"msgtype"] integerValue];
    switch (msgType) {
        case 12: { //收到评论通知
            //收到通知以后保存到本地
            CommentNotification *notification = [[CommentNotification alloc] init];
            notification.topiccode = userInfo[@"topiccode"];
            notification.usercode = userInfo[@"usercode"];
            notification.username = userInfo[@"username"];
            notification.noticontent = [userInfo valueForKeyPath:@"aps.alert"];
            notification.readstatus = @0; //消息未读
            //保存完本地信息,然后刷新UI
            [[DataBaseManager shareInstance] saveCommentNotification:notification];

            Message_RootViewController *vc = (Message_RootViewController *)[UIViewController message_rootVC];
            [vc tableViewDidTriggerHeaderRefresh];
        }
            break;
        case 14: { //强制退出
            NSString *alertStr = [userInfo valueForKeyPath:@"aps.alert"]; //获取强制退出的信息
            //如果用户是登录状态
            if ([Login isLogin]) {
                [Login doLogout];
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
                [UIAlertView bk_showAlertViewWithTitle:alertStr message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
            }
        }
            break;
        case 21: { //收到好友请求
            Contact_RootViewController *vc = (Contact_RootViewController *)[UIViewController contact_rootVC];
//            [vc setbo]
        }
            break;
        default:
            break;
    }
}

+ (UIViewController *)presentingVC {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[RootTabViewController class]]) {
        result = [(RootTabViewController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}

+ (void)presentVC:(UIViewController *)viewController {
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissModalViewControllerAnimated:)];
    [[self presentingVC] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Login
- (void)loginOutToLoginVC {
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
}

@end
