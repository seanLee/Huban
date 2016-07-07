//
//  Login.m
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kLoginStatus @"login_status"
#define kLoginUserDict @"user_dict"
#define kLoginDataListPath @"login_data_list_path.plist"

#import "Login.h"

static User *curLoginUser;

@implementation Login
- (BOOL)canLogin {
    if (!_userMobile || ![_userMobile isPhoneNumber]) {
        [self showHudTipStr:@"请输入正确的手机号"];
        return NO;
    }
    
    if (!_userPass || _userPass.length < 6) {
        [self showHudTipStr:@"密码长度至少为6位"];
        return NO;
    }
    
    return YES;
}

- (NSString *)requestPath {
    return @"router";
}
- (NSDictionary *)requestParams {
    NSDictionary *originPramas = @{@"method":@"user.logon",
                                   @"account":self.userMobile,
                                   @"devicetype":kCode_DeviceType.stringValue,  //deviceType
                                   @"devicecode":[NSString stringWithFormat:@"JPUSH-%@",[APService registrationID]?:@""],
                                   @"force":@"true",
                                   @"longtitude":[NSNumber numberWithDouble:_longtitude],
                                   @"latitude":[NSNumber numberWithDouble:_latitude],
                                   @"geotype":kGeotype //火星坐标
                                   ,@"location":_location?:@""};
    NSMutableDictionary *requestPramas = [[originPramas normalParams] mutableCopy];
    [requestPramas setObject:self.userPass forKey:@"password"];
    return requestPramas;
}

+ (void)doLogin:(NSDictionary *)loginData completion:(void (^)())completion{
    if (loginData) {
        //save to loginData
        curLoginUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
        [defaults setObject:[curLoginUser objectDictionary] forKey:kLoginUserDict];
        //移除本地记录的好友列表tag
        [defaults removeObjectForKey:kContactListVersion];
        [defaults synchronize];
        
        [self saveLoginData:[curLoginUser objectDictionary]];
        //save as file
        if (completion) {
            completion();
        }
    } else {
        [Login doLogout];
    }
}

+ (NSMutableDictionary *)readLoginDataList{
    NSMutableDictionary *loginDataList = [NSMutableDictionary dictionaryWithContentsOfFile:[self loginDataListPath]];
    if (!loginDataList) {
        loginDataList = [NSMutableDictionary dictionary];
    }
    return loginDataList;
}

+ (BOOL)saveLoginData:(NSDictionary *)loginData {
    BOOL saved = NO;
    if (loginData) {
        NSMutableDictionary *loginDataList = [self readLoginDataList];
        User *loginUser = [NSObject objectOfClass:@"User" fromJSON:loginData];
        if (loginUser.usermobile) {
            [loginDataList setObject:loginData forKey:loginUser.usermobile];
            saved = YES;
        }
        if (saved) {
            saved = [loginDataList writeToFile:[self loginDataListPath] atomically:YES];
        }
    }
    return saved;
}

+ (NSString *)loginDataListPath{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:kLoginDataListPath];
}

+ (void)saveLastLoginCode:(NSString *)code {
    if (code.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:code forKey:kLastLoginCode];
    [defaults synchronize];
}

+ (NSString *)lastLoginCode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLastLoginCode];
}

+ (User *)userWithMobile:(NSString *)mobile {
    NSMutableDictionary *loginDataList = [self readLoginDataList];
    NSDictionary *loginData = [loginDataList objectForKey:mobile];
    if (loginData) {
        return [NSObject objectOfClass:@"User" fromJSON:loginData];
    }
    return nil;
}

+ (BOOL)isLogin{
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    User *loginUser = [Login curLoginUser];
    if (loginStatus.boolValue && loginUser) {
        return YES;
    }else{
        return NO;
    }
}

+ (void)doLogout {
    //解除环信
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
        [defaults removeObjectForKey:kLoginUserDict];
        [defaults removeObjectForKey:kSession];
        [defaults removeObjectForKey:kUserSelectedCityCode];
        [defaults synchronize];
    } onQueue:dispatch_get_main_queue()];
}

+ (User *)curLoginUser {
    if (!curLoginUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict];
        curLoginUser = loginData?[NSObject objectOfClass:@"User" fromJSON:loginData]: nil;
    }
    return curLoginUser;
}
@end
