//
//  DataBaseManager.m
//  Huban
//
//  Created by sean on 15/10/11.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "DataBaseManager.h"
#import "DBHelper.h"
#import "Contact.h"
#import "User.h"
#import "CommentNotification.h"


@interface DataBaseManager ()
@property (strong, nonatomic) FMDatabase *fmdb;
@end

@implementation DataBaseManager
+ (instancetype)shareInstance {
    static DataBaseManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (void)initDatabase {
    //初始化数据库
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        //Region表
        if (![DBHelper exitsTable:@"PROVINCE_TABLE" withDatabase:db]) { //地区
            NSString *createUserTable = @"CREATE TABLE PROVINCE_TABLE (latitude real,longitude real,provcode text,provfull text,provmemo text,provname text,valid int)";
            [db executeUpdate:createUserTable];
        }
        if (![DBHelper exitsTable:@"REGION_TABLE" withDatabase:db]) {
            NSString *createUserTable = @"CREATE TABLE REGION_TABLE (cityarea real,citycode text,cityfull text,citylevel text,citymemo text,cityname text,cityphonecode text,citypopulation real,citypostcode text,provcode text,valid int,latitude real,longitude real)";
            [db executeUpdate:createUserTable];
        }
        if (![DBHelper exitsTable:@"CONTACT_TABLE" withDatabase:db]) { //联系人
            NSString *createContactTable = @"CREATE TABLE CONTACT_TABLE (id int,contactcode text,contactemail text,contactletter text,contactlogourl text,contactmemo text,contactmobile text,contactname text,contactuid text,holdercode text,holdername text,rosterid int,spamshield int,viewpermit int,blocked int,valid int,createdate date)";
            [db executeUpdate:createContactTable];
        }
        if (![DBHelper exitsTable:@"USER_TABLE" withDatabase:db]) { //用户
            NSString *createUserTable = @"CREATE TABLE USER_TABLE (usercode text,useruid text,usermobile text,useremail text,username text,usersign text,userlogourl text,usesex int,userrank int,usercredit int,uservitality int,provcode text,provname text,citycode text,cityname text,userTrends text)";
            [db executeUpdate:createUserTable];
        }
        if (![DBHelper exitsTable:@"COMMENT_NOTIFICATION_TABLE" withDatabase:db]) { //保存数目
            NSString *createUserTable = @"CREATE TABLE COMMENT_NOTIFICATION_TABLE (id integer PRIMARY KEY autoincrement,topiccode text,usercode text,username text,holdercode text,noticontent text,readstatus int)";
            [db executeUpdate:createUserTable];
        }
    }];
}

#pragma mark - Region
- (NSArray *)provinceList {
    NSMutableArray *provArr = [[NSMutableArray alloc] init];
    FMDatabaseQueue *queue = [DBHelper regionQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from PROVINCE_TABLE";
        FMResultSet *rs = [db executeQuery:queryStr];
        while ([rs next]) {
            Province *prov = [NSObject objectOfClass:@"Province" fromJSON:[rs resultDictionary]];
            [provArr addObject:prov];
        }
    }];
    return [provArr copy];
}

- (void)saveProvince:(Province *)prov {
    NSString *insertSql = @"REPLACE INTO PROVINCE_TABLE (latitude,longitude,provcode,provfull,provmemo,provname,valid) VALUES (?,?,?,?,?,?,?)";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [DBHelper databaseQueue];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:insertSql,prov.latitude,prov.longitude,prov.provcode,prov.provfull,prov.provmemo,prov.provname,prov.valid];
        }];
    });
}

- (void)saveRegion:(Region *)region {
    NSString *insertSql = @"REPLACE INTO REGION_TABLE (cityarea,citycode,cityfull,citylevel,citymemo,cityname,cityphonecode,citypopulation,citypostcode,latitude,longitude,provcode,valid) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [DBHelper databaseQueue];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:insertSql,region.cityarea,region.citycode,region.cityfull,region.citylevel,region.citymemo,region.cityname,region.cityphonecode,region.citypopulation,region.citypostcode,region.latitude,region.longtitude,region.provcode,region.valid];
        }];
    });
}

- (Region *)regionForFullName:(NSString *)full {
    __block Region *region = nil;
    NSString *queryStr = @"SELECT * FROM REGION_TABLE where cityfull = (?)";
    FMDatabaseQueue *queue = [DBHelper cityQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:queryStr,full];
        while ([rs next]) {
            region = [NSObject objectOfClass:@"Region" fromJSON:[rs resultDictionary]];
        }
    }];
    return region;
}

- (Region *)regionForCityCode:(NSString *)cityCode {
    __block Region *region = nil;
    NSString *queryStr = @"SELECT * FROM REGION_TABLE where citycode = (?)";
    FMDatabaseQueue *queue = [DBHelper cityQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:queryStr,cityCode];
        while ([rs next]) {
            region = [NSObject objectOfClass:@"Region" fromJSON:[rs resultDictionary]];
        }
    }];
    return region;

}

- (NSArray *)regionListForProvince:(NSString *)provCode {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *queryStr = @"SELECT * FROM REGION_TABLE where provcode = (?)";
    FMDatabaseQueue *queue = [DBHelper cityQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:queryStr,provCode];
        while ([rs next]) {
            Region *city = [NSObject objectOfClass:@"Region" fromJSON:[rs resultDictionary]];
            [list addObject:city];
        }
    }];
    return [list copy];
}
#pragma mark - Contact
- (NSArray *)queryContacts {
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from CONTACT_TABLE where holdercode = (?) and valid = (?)";
        FMResultSet *rs = [db executeQuery:queryStr,[Login curLoginUser].usercode,@1];
        while ([rs next]) {
            Contact *contact = [NSObject objectOfClass:@"Contact" fromJSON:rs.resultDictionary];
            [contactArray addObject:contact];
        }
        [rs close];
    }];
    return contactArray;
}

- (Contact *)relationForUser:(NSString *)userCode {
    __block Contact *relation = nil;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from CONTACT_TABLE where holdercode = (?) and contactcode = (?)";
        FMResultSet *rs = [db executeQuery:queryStr,[Login curLoginUser].usercode,userCode];
        while ([rs next]) {
            relation = [NSObject objectOfClass:@"Contact" fromJSON:[rs resultDictionary]];
        }
        [rs close];
    }];
    return relation;
}

- (BOOL)updateContact:(Contact *)contact {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
       NSString *queryStr = @"UPDATE CONTACT_TABLE SET id = ?,blocked = ?,rosterid = ?,spamshield = ?,valid = ?,viewpermit = ?,contactemail = ?,contactletter = ?,contactlogourl = ?,contactmemo = ?,contactmobile = ?,contactname = ?,contactuid = ?,holdername = ?,createdate = ? WHERE contactcode = ? and holdercode = ?";
        updated = [db executeUpdate:queryStr,contact.id,contact.blocked,contact.rosterid,contact.spamshield,contact.valid,contact.viewpermit,contact.contactemail,contact.contactletter,contact.contactlogourl,contact.contactmemo,contact.contactmobile,contact.contactname,contact.contactuid,contact.holdername,contact.createdate,contact.contactcode,contact.holdercode];
    }];
    return updated;
}

- (BOOL)saveContact:(Contact *)contact {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"REPLACE INTO CONTACT_TABLE (id,blocked,rosterid,spamshield,valid,viewpermit,contactemail,contactletter,contactlogourl,contactmemo,contactmobile,contactname,contactuid,holdername,createdate,contactcode,holdercode) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        updated = [db executeUpdate:queryStr,contact.id,contact.blocked,contact.rosterid,contact.spamshield,contact.valid,contact.viewpermit,contact.contactemail,contact.contactletter,contact.contactlogourl,contact.contactmemo,contact.contactmobile,contact.contactname,contact.contactuid,contact.holdername,contact.createdate,contact.contactcode,contact.holdercode];
    }];
    return updated;
}

- (BOOL)deleteContact:(Contact *)deletedObj {
    __block BOOL deleted = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = [NSString stringWithFormat:@"delete from CONTACT_TABLE Where contactcode = '%@' and holdercode = '%@'",deletedObj.contactcode,deletedObj.holdercode];
        deleted = [db executeUpdate:queryStr];
    }];
    return deleted;
}

#pragma mark - User
- (User *)userByUserCode:(NSString *)userCode {
    __block User *user;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from USER_TABLE where usercode = ?";
        FMResultSet *rs = [db executeQuery:queryStr,userCode];
        while ([rs next]) {
            user = [NSObject objectOfClass:@"User" fromJSON:[rs resultDictionary]];
        }
        [rs close];
    }];
    return user;
}

- (User *)userbyUserMoblie:(NSString *)userMobile {
    __block User *user;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from USER_TABLE where usermobile = ?";
        FMResultSet *rs = [db executeQuery:queryStr,userMobile];
        while ([rs next]) {
            user = [NSObject objectOfClass:@"User" fromJSON:[rs resultDictionary]];
        }
        [rs close];
    }];
    return user;
}

- (BOOL)saveUser:(User *)user {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"REPLACE INTO USER_TABLE (usercode,useruid,usermobile,useremail,username,usersign,userlogourl,usesex,userrank,usercredit,uservitality,provcode,provname,citycode,cityname,userTrends) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        updated = [db executeUpdate:queryStr,user.usercode,user.useruid,user.usermobile,user.usermobile,user.username,user.usersign,user.userlogourl,user.usersex,user.userrank,user.usercredit,user.uservitality,user.provcode,user.provname,user.citycode,user.cityname,user.userTrends];
    }];
    return updated;
}

- (BOOL)deleteUser:(User *)user {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"delete from USER_TABLE where usercode = ?";
        updated = [db executeUpdate:queryStr,user.usercode];
    }];
    return updated;}

#pragma mark - Comment Notification
- (BOOL)saveCommentNotification:(CommentNotification *)comment {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"REPLACE INTO COMMENT_NOTIFICATION_TABLE (topiccode,usercode,username,holdercode,readstatus,noticontent) VALUES(?,?,?,?,?,?)";
        updated = [db executeUpdate:queryStr,comment.topiccode,comment.usercode,comment.username,[Login curLoginUser].usercode,comment.readstatus,comment.noticontent];
    }];
    return updated;
}

- (BOOL)removeAllNoficatonInfo {
    __block BOOL updated = NO;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"DELETE FROM COMMENT_NOTIFICATION_TABLE WHERE holdercode = ?";
        updated = [db executeUpdate:queryStr,[Login curLoginUser].usercode];
    }];
    return updated;
}

- (NSNumber *)numberOfCommentNotification {
    __block NSNumber *count = @0;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select count(*) from COMMENT_NOTIFICATION_TABLE where readstatus = 0 and holdercode = ?";
        FMResultSet *rs = [db executeQuery:queryStr,[Login curLoginUser].usercode];
        while ([rs next]) {
            count = [rs resultDictionary][[rs columnNameForIndex:0]];
        }
        [rs close];
    }];
    return count;
}

- (CommentNotification *)lastCommentNotification {
    __block CommentNotification *notification;
    FMDatabaseQueue *queue = [DBHelper databaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *queryStr = @"select * from COMMENT_NOTIFICATION_TABLE where id = (select max(id) from COMMENT_NOTIFICATION_TABLE) and holdercode = ?";
        FMResultSet *rs = [db executeQuery:queryStr,[Login curLoginUser].usercode];
        while ([rs next]) {
            notification = [NSObject objectOfClass:@"CommentNotification" fromJSON:[rs resultDictionary]];
        }
        [rs close];
    }];
    return notification;
}
@end
