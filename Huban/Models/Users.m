//
//  Users.m
//  Huban
//
//  Created by sean on 15/10/15.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Users.h"

@implementation Users
- (NSMutableArray *)list {
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toSearchParams {
    return @{@"method":@"user.pagerbykeyword",@"keyword":_queryText
             ,@"usertyepe":@1,@"start":@(_start),@"limit":@(_limit)};
}
@end
