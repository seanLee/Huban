//
//  NearByPersons.h
//  Huban
//
//  Created by sean on 15/12/1.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearByPersons : NSObject
@property (strong, nonatomic) NSMutableArray *list;
@property (assign, nonatomic) NSInteger curPage;
@property (strong, nonatomic) NSNumber *latitude, *longtitude;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

- (NSString *)toPath;

- (NSDictionary *)toParams;

- (void)configWithNearBys:(NSDictionary *)dataList;
@end
