//
//  Topics.m
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Topics.h"

@implementation Topics
- (NSString *)toPath {
    return @"router";
}
- (NSDictionary *)toCityCircleParams {
    NSDictionary *params = @{@"method":@"topic.pagerbycity",@"citycode":_curRegion.citycode,@"start":@(_curPage++*20),@"limit":@20};
    return params;
}
- (NSDictionary *)toUserParams {
    return @{@"method":@"topic.pagerbyholder",@"holdercode":_userCode,@"isown":@([_userCode isEqualToString:[Login curLoginUser].usercode]),@"start":@(_curPage++*20),@"limit":@20};
}
- (NSDictionary *)toCollectionParams {
    return @{@"method":@"topic.favorite.pagerbyuser",@"holdercode":_userCode,@"isown":@([_userCode isEqualToString:[Login curLoginUser].usercode]),@"start":@(_curPage++*20),@"limit":@20,@"usercode":[Login curLoginUser].usercode};
}
- (NSDictionary *)toFriendParams {
    return @{@"method":@"topic.pagerbycontact",@"start":@(_curPage++*20),@"limit":@20};
}

- (void)configWithTopics:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"Topic"];
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

- (void)configWithFavoriteTopics:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"FavoriteTopic"];
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
