//
//  FavoriteTopics.h
//  Huban
//
//  Created by sean on 15/12/15.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteTopics : NSObject
@property (strong, nonatomic) NSMutableArray *list;
@property (strong, nonatomic) NSDate *curDate;
@property (strong, nonatomic) NSString *userCode;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) NSInteger curPage;

- (void)configWithFavoriteTopics:(NSDictionary *)dataList;
@end
