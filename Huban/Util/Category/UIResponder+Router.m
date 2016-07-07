//
//  UIResponder+Router.m
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UIResponder+Router.h"

@implementation UIResponder (Router)
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}
@end
