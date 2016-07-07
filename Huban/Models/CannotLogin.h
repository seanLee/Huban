//
//  CannotLogin.h
//  Huban
//
//  Created by sean on 15/8/12.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, CannotLoginType) {
    CannotLoginTypeRegister = 0,
    CannotLoginTypeModefyCode
};

#import <Foundation/Foundation.h>

@interface CannotLogin : NSObject
@property (strong, nonatomic) NSString *userMobile, *userPass, *repeatPass, *originPass, *rndCode, *captcha;

@property (assign, nonatomic) CannotLoginType operationType;

- (NSString *)requestPath;
- (NSDictionary *)requestParams;

- (NSString *)captchaPath;
- (NSDictionary *)captchaParams;

- (NSDictionary *)resetPassParams;

- (BOOL)canSubmit;
- (BOOL)isCaptchaMatched:(NSString *)captcha;
@end
