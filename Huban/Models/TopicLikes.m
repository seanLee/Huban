//
//  TopicLikes.m
//  Huban
//
//  Created by sean on 15/11/26.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "TopicLikes.h"

@implementation TopicLikes
- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toParams {
    return @{@"method":@"topic.approve.pager",@"topiccode":self.topicCode,@"start":@0,@"limit":@0};
}

- (void)configWithLikes:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"TopicLike"];
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
