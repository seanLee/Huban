//
//  DataBaseManager.h
//  Huban
//
//  Created by sean on 15/10/11.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Region;
@class Contact;
@class User;
@class CommentNotification;
@class Province;

@interface DataBaseManager : NSObject
+ (instancetype)shareInstance;

- (void)initDatabase;

#pragma mark - Region
- (NSArray *)provinceList;
- (void)saveProvince:(Province *)prov;
- (void)saveRegion:(Region *)region;

- (Region *)regionForFullName:(NSString *)full;
- (Region *)regionForCityCode:(NSString *)cityCode;
- (NSArray *)regionListForProvince:(NSString *)provCode;

#pragma mark - Contact
- (NSArray *)queryContacts;
- (Contact *)relationForUser:(NSString *)userCode;
- (BOOL)updateContact:(Contact *)contact;
- (BOOL)saveContact:(Contact *)contact;
- (BOOL)deleteContact:(Contact *)deletedObj;

#pragma mark - User
- (User *)userByUserCode:(NSString *)userCode;
- (User *)userbyUserMoblie:(NSString *)userMobile;
- (BOOL)saveUser:(User *)user;
- (BOOL)deleteUser:(User *)user;

#pragma mark - Comment Notification
- (BOOL)saveCommentNotification:(CommentNotification *)comment;
- (BOOL)removeAllNoficatonInfo;
- (NSNumber *)numberOfCommentNotification;
- (CommentNotification *)lastCommentNotification;
@end
