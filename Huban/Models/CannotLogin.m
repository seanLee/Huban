//
//  CannotLogin.m
//  Huban
//
//  Created by sean on 15/8/12.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CannotLogin.h"

@implementation CannotLogin

- (NSString *)registerPath {
    return @"router";
}
- (NSDictionary *)registerParams {
    NSDictionary *originParams = @{@"method":@"user.register",@"usermobile":_userMobile
                                   ,@"usertype":@1,@"userstate":@1};
    NSMutableDictionary *requestPramas = [[originParams normalParams] mutableCopy];
    [requestPramas setObject:_userPass forKey:@"userpass"];
    
    return requestPramas;
}

- (NSString *)modefyPath {
    return @"router";
}
- (NSDictionary *)modefyParams {
    NSDictionary *originParams = @{@"method":@"user.getpass.chgpass",@"usermobile":_userMobile
                                   ,@"rndcode":_rndCode};
    NSLog(@"%@",_captcha);
    NSMutableDictionary *requestPramas = [[originParams normalParams] mutableCopy];
    [requestPramas setObject:_userPass forKey:@"userpass"];
    return requestPramas;
}

- (NSString *)captchaPath {
    return @"router";
}
- (NSDictionary *)captchaParams {
    NSDictionary *originPramas;
    if (_operationType == CannotLoginTypeRegister) {
        originPramas = @{@"method":@"user.register.sendsms",@"usermobile":_userMobile};
    } else {
        originPramas = @{@"method":@"user.getpass.sendsms",@"usermobile":_userMobile};
    }
    return [originPramas normalParams];
}

- (NSString *)requestPath {
    if (_operationType == CannotLoginTypeRegister) {
        return [self registerPath];
    }
    return [self modefyPath];
}
- (NSDictionary *)requestParams {
    if (_operationType == CannotLoginTypeRegister) {
        return [self registerParams];
    }
    return [self modefyParams];
}

- (NSDictionary *)resetPassParams {
    NSDictionary *params = @{@"method":@"user.chgpass",@"usercode":[[Login curLoginUser] usercode]};
    NSMutableDictionary *requestParams = [[params sessionParams] mutableCopy];
    [requestParams setObject:_originPass forKey:@"oldpass"];
    [requestParams setObject:_userPass forKey:@"newpass"];
    return requestParams;
}

- (BOOL)canSubmit {
    if (!_userMobile || _userMobile.length < 11) {
        [self showHudTipStr:@"请输入正确的手机号"];
        return NO;
    }
    if (!_userPass || _userPass.length < 6) {
        [self showHudTipStr:@"请输入正确的密码"];
        return NO;
    }
    if (!_repeatPass || ![_repeatPass isEqualToString:_userPass]) {
        [self showHudTipStr:@"密码输入不一致"];
        return NO;
    }
    return YES;
}

- (BOOL)isCaptchaMatched:(NSString *)captcha {
    if (!_captcha || ![_captcha isEqualToString:captcha]) {
        kTipAlert(@"请输入正确的验证码");
        return NO;
    }
    
    return YES;
}
@end
