//
//  Topics.h
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Topic.h"
#import "FavoriteTopic.h"
@class Province;
@class Region;

@interface Topics : NSObject
@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) NSDate *curDate;
@property (strong, nonatomic) NSString *userCode;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) NSInteger curPage;

@property (strong, nonatomic) Region *curRegion ;

- (NSString *)toPath;

- (NSDictionary *)toCityCircleParams;
- (NSDictionary *)toUserParams;
- (NSDictionary *)toCollectionParams;
- (NSDictionary *)toFriendParams;

- (void)configWithTopics:(NSDictionary *)dataList;
- (void)configWithFavoriteTopics:(NSDictionary *)dataList;
@end
