//
//  BaseViewController.h
//  Huban
//
//  Created by sean on 15/7/25.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
- (void)tabBarItemClicked;
- (void)loginOutToLoginVC;

+ (void)handleNotification:(NSDictionary *)userInfo applicationState:(UIApplicationState)applicationState;
//+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr;
+ (UIViewController *)presentingVC;
+ (void)presentVC:(UIViewController *)viewController;
@end
