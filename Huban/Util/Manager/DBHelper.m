//
//  DBHelper.m
//  Huban
//
//  Created by sean on 15/10/12.
//  Copyright © 2015年 sean. All rights reserved.
//

#define SQLITE_NAME @"models.sqlite"

#import "DBHelper.h"

@implementation DBHelper
+ (FMDatabaseQueue *)databaseQueue {
    static FMDatabaseQueue *share_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:SQLITE_NAME];
        NSLog(@"%@",filePath);
        share_instance = [[FMDatabaseQueue alloc] initWithPath:filePath];
    });
    return share_instance;
}

+ (FMDatabaseQueue *)regionQueue {
    static FMDatabaseQueue *share_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"province.sqlite"];
        share_instance = [[FMDatabaseQueue alloc] initWithPath:filePath];
    });
    return share_instance;
}

+ (FMDatabaseQueue *)cityQueue {
    static FMDatabaseQueue *share_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"city.sqlite"];
        share_instance = [[FMDatabaseQueue alloc] initWithPath:filePath];
    });
    return share_instance;
}

+ (BOOL)exitsTable:(NSString *)tableName withDatabase:(FMDatabase *)database {
    FMResultSet *rs = [database executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next]) {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        [rs close];
        if (0 == count) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}
@end
