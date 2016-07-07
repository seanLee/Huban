//
//  TopicComments.m
//  Huban
//
//  Created by sean on 15/11/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "TopicComments.h"

@implementation TopicComments
- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toCommentsParams {
    return @{@"method":@"topic.comment.pager",@"topiccode":self.topicCode,@"start":@(self.curPage++),@"limit":@20,@"zonal":self.commentType == CommentType_CityCircle?@1:@0};
}

- (void)configWithComments:(NSDictionary *)dataList {
    NSArray *dataArr = [NSObject arrayFromJSON:dataList[@"list"] ofObjects:@"TopicComment"];
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
