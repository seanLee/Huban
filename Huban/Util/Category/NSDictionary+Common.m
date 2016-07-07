//
//  NSDictionary+Common.m
//  Huban
//
//  Created by sean on 15/9/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "NSDictionary+Common.h"

@implementation NSDictionary (Common)
- (NSDictionary *)requestParamsWithSession:(BOOL)hasSession {
    NSMutableDictionary *requestParams = [self mutableCopy];
    [requestParams setObject:kBaseAppCode forKey:@"appcode"];   //appcode
    [requestParams setObject:kCode_Version forKey:@"v"];        //version
    [requestParams setObject:@"json" forKey:@"format"];         //response type
    [requestParams setObject:@"zh_CN" forKey:@"locale"];        //locale
    
    if (hasSession) { //登录后
        NSUserDefaults *defauls = [NSUserDefaults standardUserDefaults];
        NSString *sessionId = [defauls objectForKey:kSession];
        if (sessionId && sessionId.length > 0) {
            [requestParams setObject:sessionId forKey:@"session"];
        }
    }
    
    //对所有的key进行排序
    NSArray *allkeys = [requestParams allKeys];
    allkeys = [allkeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    //sing字符串
    NSMutableString *signStr = [[NSMutableString alloc] init];
    for (NSString *subStr in allkeys) {
        [signStr appendFormat:@"%@%@",subStr,requestParams[subStr]];
    }
    //首尾加入appsecret
    NSString *secretSingStr = [NSString stringWithFormat:@"%@%@%@",kBaseAppSecret,signStr,kBaseAppSecret];
    //加密
    NSString *sha1Str = [secretSingStr sha1Str];
    //加入参数
    [requestParams setObject:sha1Str forKey:@"sign"];
    return [requestParams copy];
}

- (NSDictionary *)normalParams {
    return [self requestParamsWithSession:NO];
}

- (NSDictionary *)sessionParams {
    return [self requestParamsWithSession:YES];
}
@end
