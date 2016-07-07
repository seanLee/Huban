//
//  TopicLikes.h
//  Huban
//
//  Created by sean on 15/11/26.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopicLike.h"

@interface TopicLikes : NSObject
@property (strong, nonatomic) NSString *topicCode;
@property (strong, nonatomic) NSMutableArray *list;
@property (assign, nonatomic) NSInteger curPage;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

- (NSString *)toPath;

- (NSDictionary *)toParams;

- (void)configWithLikes:(NSDictionary *)dataList;
@end
