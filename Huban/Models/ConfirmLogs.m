//
//  ConfirmLogs.m
//  Huban
//
//  Created by sean on 15/10/9.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "ConfirmLogs.h"

@implementation ConfirmLogs
- (NSString *)toPath {
    return @"router";
}
- (NSDictionary *)toParams {
    return @{@"method":@"common.logconfirm.pagerbyholder",@"holdercode":[Login curLoginUser].usercode,@"start":@0,@"limit":@20};
}
@end
