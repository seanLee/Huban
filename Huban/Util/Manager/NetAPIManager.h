//
//  NetAPIManager.h
//  Huban
//
//  Created by sean on 15/9/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAPIClient.h"
#import "NSDictionary+Common.h"

@interface NetAPIManager : NSObject
+ (instancetype)shareManager;

#pragma mark - Region
- (void)request_get_regionInfoWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - ImageURL
- (void)request_image_rooturlWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateSingleImage:(NSDictionary *)params withSize:(double)size andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Account
- (void)request_get_codeWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_captchtWithPhone:(NSString *)phone andBlock:(void (^)(id data, NSError *error))block;
- (void)request_login_withParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_register_withParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_modefyCode_withParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_reset_passWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - User
- (void)request_get_userWithMobile:(NSString *)mobile andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_userWithUsercode:(NSString *)usercode andBlock:(void (^)(id data, NSError *error))block;
- (void)request_logoutWithBlock:(void (^)(id data, NSError *error))block;
//userinfo
- (void)request_updateUserInfo:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateRegionInfo:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateNeedConfirmWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateSpamshieldWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateViewpermitWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_updateLocationWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Users
- (void)request_searchUserByKeywordWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Contact
- (void)request_get_contactListVersionWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_contactWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_contactListWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_add_contactWithParams:(id)addedUser withMemo:(NSString *)memo andBlock:(void (^)(id data, NSError *error))block;
- (void)request_delete_contactWithParams:(id)deleteUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_contact_changeBlockWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_contact_changeMemoWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_contact_changeSpamshieldWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
#pragma mark - BlackList
- (void)request_contact_blackListWithBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Confirm
- (void)request_get_confirmsWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Topic
- (void)request_get_topicWithParams:(NSString *)topicCode andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_cityCircleTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_albumTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_friendTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_collectionTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;;
- (void)request_sendTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_deleteTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_shieldTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_complainTopicWithParams:(id)params andType:(NSInteger)complainType andBlock:(void (^)(id data, NSError *error))block;
- (void)request_favoriteTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_approveTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

- (void)request_delete_favoriteWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - TopicComment
- (void)request_get_commentToTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_get_commentsOfTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_delete_commentOfTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Likes
- (void)request_get_likesToTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - File
- (void)uploadImagesWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - FeedBack
- (void)request_feedBackWithMessage:(NSString *)message andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - NearBy
- (void)request_nearByWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Session
- (void)request_keepAliveWithBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Location
- (void)request_locationWithLat:(double)latitude andLon:(double)lontitude andBlock:(void (^)(id data, NSError *error))block;
@end
