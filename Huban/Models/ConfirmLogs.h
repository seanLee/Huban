//
//  ConfirmLogs.h
//  Huban
//
//  Created by sean on 15/10/9.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfirmLogs : NSObject
@property (strong, nonatomic) User *holder;
@property (strong, nonatomic) NSMutableArray *list;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;

- (NSString *)toPath;
- (NSDictionary *)toParams;

@end
