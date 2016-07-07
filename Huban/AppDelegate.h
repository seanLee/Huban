//
//  AppDelegate.h
//  Huban
//
//  Created by sean on 15/7/22.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setupTabBarViewController;
- (void)setupLoginViewController;
- (void)setupIntroductionViewController;

@end

