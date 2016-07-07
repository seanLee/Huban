//
//  DBHelper.h
//  Huban
//
//  Created by sean on 15/10/12.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject
+ (FMDatabaseQueue *)databaseQueue;
+ (FMDatabaseQueue *)regionQueue;
+ (FMDatabaseQueue *)cityQueue;
+ (BOOL)exitsTable:(NSString *)tableName withDatabase:(FMDatabase *)database;
@end
