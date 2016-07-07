//
//  UIViewController+Common.m
//  Huban
//
//  Created by sean on 15/11/10.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "UIViewController+Common.h"
#import "BaseNavigationController.h"
#import "RDVTabBarController.h"

@implementation UIViewController (Common)
+ (UIViewController *)message_rootVC {
    RDVTabBarController *baseVC = (RDVTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController; //获取window
    BaseNavigationController *navVC = [baseVC.viewControllers objectAtIndex:0]; //获取nav
    return navVC.topViewController;
}

+ (UIViewController *)contact_rootVC {
    RDVTabBarController *baseVC = (RDVTabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController; //获取window
    BaseNavigationController *navVC = [baseVC.viewControllers objectAtIndex:1]; //获取nav
    return navVC.topViewController;
}
@end
