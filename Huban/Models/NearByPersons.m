//
//  NearByPersons.m
//  Huban
//
//  Created by sean on 15/12/1.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "NearByPersons.h"

@implementation NearByPersons
- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toParams {
    return @{@"method":@"user.pagerbylocate",@"start":@(_curPage++*20),@"limit":@20,@"longitude":self.longtitude,@"latitude":self.latitude,@"geotype":kGeotype};
}

- (void)configWithNearBys:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"User"];
    NSNumber *count = dataList[@"count"];
    if (dataArr && dataArr.count > 0) {
        self.canLoadMore = (_curPage*20 < count.intValue);
        if (_willLoadMore) {
            [self.list addObjectsFromArray:dataArr];
        } else {
            self.list = [NSMutableArray arrayWithArray:dataArr];
        }
    } else {
        self.canLoadMore = NO;
        if (!_willLoadMore) {
            self.list = [NSMutableArray array];
        }
    }
}
@end
