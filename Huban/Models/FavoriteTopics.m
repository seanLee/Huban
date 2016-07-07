//
//  FavoriteTopics.m
//  Huban
//
//  Created by sean on 15/12/15.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "FavoriteTopics.h"

@implementation FavoriteTopics
- (void)configWithFavoriteTopics:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"FavoriteTopic"];
    NSMutableArray *addedArray = [[NSMutableArray alloc] init];
    NSNumber *count = dataList[@"count"];
    for (Topic *item in dataArr) {
        if (!item.shield.boolValue) { //没有被屏蔽的才会被加入数据中
            [addedArray addObject:item];
        }
    }
    if (addedArray && addedArray.count > 0) {
        self.canLoadMore = (_curPage*20 < count.intValue);
        if (_willLoadMore) {
            [self.list addObjectsFromArray:addedArray];
        } else {
            self.list = [NSMutableArray arrayWithArray:addedArray];
        }
    } else {
        self.canLoadMore = NO;
        if (!_willLoadMore) {
            self.list = [NSMutableArray array];
        }
    }
}
@end
