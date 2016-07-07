//
//  Login.h
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Login : NSObject
@property (strong, nonatomic) NSString *userMobile, *userPass;
@property (assign, nonatomic) double longtitude, latitude;
@property (strong, nonatomic) NSString *location;

+ (User *)curLoginUser;

- (NSString *)requestPath;
- (NSDictionary *)requestParams;

- (BOOL)canLogin;
+ (BOOL) isLogin;
+ (void) doLogin:(NSDictionary *)loginData completion:(void (^)())completion;
+ (void) doLogout;

+ (void)saveLastLoginCode:(NSString *)code;
+ (NSString *)lastLoginCode;
+ (User *)userWithMobile:(NSString *)mobile;
@end
