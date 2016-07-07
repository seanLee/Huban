//
//  NetAPIManager.m
//  Huban
//
//  Created by sean on 15/9/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "NetAPIManager.h"
#import "CannotLogin.h"
#import "Contacts.h"
#import "TopicComments.h"
#import "TopicLikes.h"
#import "NearByPersons.h"

@implementation NetAPIManager
+ (instancetype) shareManager {
    static NetAPIManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

#pragma mark - Region
- (void)request_get_regionInfoWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params normalParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

#pragma mark - ImageURL
- (void)request_image_rooturlWithBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"cfile.siteurl"};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params normalParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_updateSingleImage:(NSDictionary *)params withSize:(double)size andBlock:(void (^)(id, NSError *))block {
    NSDictionary *originParams = @{@"filetype":@1,@"filesize":[NSNumber numberWithDouble:size],@"method":@"cfile.upload"};//请求参数
    NSDictionary *sessionParams = [originParams sessionParams]; //加入签名
    NSMutableDictionary *requestParams = [sessionParams mutableCopy];
    [requestParams setObject:params[@"filedata"] forKey:@"filedata"]; //加入文件
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:requestParams withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

#pragma mark - Account
- (void)request_get_codeWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[CannotLogin class]]) {
        CannotLogin *captcha = (CannotLogin *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[captcha captchaPath] withParams:[captcha captchaParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_captchtWithPhone:(NSString *)phone andBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"user.register.sendsms",@"usermobile":phone};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params normalParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_register_withParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[CannotLogin class]]) {
        CannotLogin *curAccount = (CannotLogin *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[curAccount requestPath] withParams:[curAccount requestParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_login_withParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Login class]]) {
        Login *curLogin = (Login *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[curLogin requestPath] withParams:[curLogin requestParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                //用户登录,指定推送对象
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_modefyCode_withParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[CannotLogin class]]) {
        CannotLogin *curAccount = (CannotLogin *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[curAccount requestPath] withParams:[curAccount requestParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_reset_passWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[CannotLogin class]]) {
        CannotLogin *curAccount = (CannotLogin *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[curAccount requestPath] withParams:[curAccount resetPassParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - User
- (void)request_get_userWithMobile:(NSString *)mobile andBlock:(void (^)(id, NSError *))block {
    NSDictionary *paramsDict = @{@"usermobile":mobile,@"method":@"user.querybymobile"};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[paramsDict sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_get_userWithUsercode:(NSString *)usercode andBlock:(void (^)(id, NSError *))block {
    NSDictionary *paramsDict = @{@"usercode":usercode,@"method":@"user.query"};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[paramsDict sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_logoutWithBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"user.logout"};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [Login doLogout];
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}
//userinfo
- (void)request_updateUserInfo:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[[user toUpdateParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [self request_get_userWithMobile:user.usermobile andBlock:^(id userData, NSError *error) {
                    if (userData) {
                        [Login doLogin:userData completion:nil]; //update the local infomation
                    }
                }];
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_updateRegionInfo:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[[user toUpdateRegionParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [self request_get_userWithMobile:user.usermobile andBlock:^(id userData, NSError *error) {
                    if (userData) {
                        [Login doLogin:userData completion:nil]; //update the local infomation
                    }
                }];
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_updateNeedConfirmWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        NSDictionary *dictParams = @{@"method":@"user.chgneedconfirm",@"needconfirm":user.needconfirm,@"usercode":user.usercode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[dictParams sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_updateSpamshieldWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        NSDictionary *dictParams = @{@"method":@"user.chgspamshield",@"spamshield":user.spamshield,@"usercode":user.usercode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[dictParams sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_updateViewpermitWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        NSDictionary *dictParams = @{@"method":@"user.chgviewpermit",@"viewpermit":user.viewpermit,@"usercode":user.usercode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[dictParams sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_updateLocationWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[User class]]) {
        User *user = (User *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[user toUpdatePath] withParams:[[user refreshLocationParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [self request_get_userWithMobile:user.usermobile andBlock:^(id userData, NSError *error) {
                    if (userData) {
                        [Login doLogin:userData completion:nil]; //update the local infomation
                    }
                }];
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - Users
- (void)request_searchUserByKeywordWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Users class]]) {
        Users *users = (Users *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[users toPath] withParams:[[users toSearchParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - Contact
- (void)request_get_contactListVersionWithBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"common.tag.query",@"tagname":[NSString stringWithFormat:@"tag.contact.%@",[Login curLoginUser].usercode]};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_get_contactWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[NSString class]]) {
        NSString *userCode = params;
        NSDictionary *params = @{@"method":@"user.contact.query",@"holdercode":[Login curLoginUser].usercode,@"contactcode":userCode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_contactListWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Contacts class]]) {
        Contacts *contacts = (Contacts *)params;
        contacts.isLoading = YES;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contacts requestPath] withParams:[[contacts requestParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            contacts.isLoading = NO;
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_add_contactWithParams:(id)addedUser withMemo:(NSString *)memo andBlock:(void (^)(id, NSError *))block {
    if ([addedUser isKindOfClass:[User class]]) {
        User *user = (User *)addedUser;
        if ([user.usercode isEqual:[Login curLoginUser].usercode]) {
            kTipAlert(@"不能添加自己为好友");
        } else {
            Contact *contact = [[Contact alloc] init];
            contact.confirmmemo = memo?:@"";
            contact.holdercode = [Login curLoginUser].usercode;
            contact.contactcode = user.usercode;
            [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contact toPath] withParams:[[contact addedParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
                if (data) {
                    block(data,nil);
                } else {
                    block(nil,error);
                }
            }];
        }
    }
}

- (void)request_delete_contactWithParams:(id)deleteUser andBlock:(void (^)(id, NSError *))block {
    if ([deleteUser isKindOfClass:[Contact class]]) {
        Contact *contact = (Contact *)deleteUser;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contact toPath] withParams:[[contact deletedParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_contact_changeBlockWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Contact class]]) {
        Contact *contact = (Contact *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contact toPath] withParams:[[contact blockParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_contact_changeMemoWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Contact class]]) {
        Contact *contact = (Contact *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contact toPath] withParams:[[contact changeMemoParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_contact_changeSpamshieldWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Contact class]]) {
        Contact *contact = (Contact *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[contact toPath] withParams:[[contact changeSpamshieldParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - BlackList
- (void)request_contact_blackListWithBlock:(void (^)(id data, NSError *error))block {
    NSDictionary *params = @{@"method":@"user.contact.pagerbyblocked",@"holdercode":[Login curLoginUser].usercode,@"start":@0,@"limit":@0};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
        
    }];
}
#pragma mark - Confirms
- (void)request_get_confirmsWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[ConfirmLogs class]]) {
        ConfirmLogs *curLogs = (ConfirmLogs *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[curLogs toPath] withParams:[[curLogs toParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - Topic
- (void)request_get_topicWithParams:(NSString *)topicCode andBlock:(void (^)(id, NSError *))block {
    Topic *topic = [[Topic alloc] init];
    topic.topiccode = topicCode;
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[[topic toQueryParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

- (void)request_get_cityCircleTopicWithParams:(id)params andBlock:(void (^)(id data, NSError *error))block {
    if ([params isKindOfClass:[Topics class]]) {
        Topics *topics = (Topics *)params;
        topics.isLoading = YES;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topics toPath] withParams:[[topics toCityCircleParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            topics.isLoading = NO;
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_albumTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topics class]]) {
        Topics *topics = (Topics *)params;
        topics.isLoading = YES;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topics toPath] withParams:[[topics toUserParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            topics.isLoading = NO;
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_friendTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topics class]]) {
        Topics *topics = (Topics *)params;
        topics.isLoading = YES;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topics toPath] withParams:[[topics toFriendParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            topics.isLoading = NO;
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_collectionTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topics class]]) {
        Topics *topics = (Topics *)params;
        topics.isLoading = YES;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topics toPath] withParams:[[topics toCollectionParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            topics.isLoading = NO;
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_sendTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[[topic toCreateParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_deleteTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[[topic toDeleteParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_shieldTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[[topic toShieldParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_complainTopicWithParams:(id)params andType:(NSInteger)complainType andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        NSDictionary *params = @{@"method":@"topic.complain.create",@"complaincontent":@"",@"complaintype":@(complainType),@"topiccode":topic.topiccode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[params sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                topic.complainnum = [NSNumber numberWithInteger:topic.complainnum.integerValue + 1];
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_favoriteTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        NSDictionary *params = @{@"method":topic.favorite.boolValue?@"topic.favorite.delete":@"topic.favorite.create",@"topiccode":topic.topiccode};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[params sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                NSInteger favoriteTag = topic.favorite.integerValue;
                if (favoriteTag == 0) {//如果没有收藏
                    topic.favorite = @1;
                } else if (favoriteTag == 1) { //如果用户收藏,就反选
                    topic.favorite = @0;
                }
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_approveTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[topic toPath] withParams:[[topic toApproveParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_delete_favoriteWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[NSString class]]) {
        NSDictionary *paramDict = @{@"method":@"topic.favorite.delete",@"topiccode":params};
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[paramDict sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
            
        }];
    }
}
#pragma mark - TopicComment
- (void)request_get_commentToTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[TopicComment class]]) {
        TopicComment *comment = (TopicComment *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[comment toPath] withParams:[[comment toCommentParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_get_commentsOfTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[TopicComments class]]) {
        TopicComments *comments = (TopicComments *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[comments toPath] withParams:[[comments toCommentsParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

- (void)request_delete_commentOfTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[TopicComment class]]) {
        TopicComment *comment = (TopicComment *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[comment toPath] withParams:[[comment toDeleteParams] sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - Likes
- (void)request_get_likesToTopicWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[TopicLikes class]]) {
        TopicLikes *likeList = (TopicLikes *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[likeList toPath] withParams:[[likeList toParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - File
- (void)uploadImagesWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)params;
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (TopicImage *curImage in curTopic.topicImageArray) {
            [images addObject:curImage.image];
        }
        [[NetAPIClient shareJsonClient] uploadTopicImagesWithPath:[curTopic imagePath] withParams:[[curTopic imageParams] normalParams] withImages:images withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                NSArray *reponseArr = data[@"list"];
                NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in reponseArr) {
                    [tempArr addObject:dict[@"path"]];
                }
                NSString *filePaths = [tempArr componentsJoinedByString:@","];
                block(filePaths,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - FeedBack
- (void)request_feedBackWithMessage:(NSString *)message andBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"common.logfeedback.create",@"code":[Login curLoginUser].usercode,@"name":[Login curLoginUser].username,@"desc":message};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params sessionParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

#pragma mark - NearBy
- (void)request_nearByWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    if ([params isKindOfClass:[NearByPersons class]]) {
        NearByPersons *nearBy = (NearByPersons *)params;
        [[NetAPIClient shareJsonClient] requestJsonDataWithPath:[nearBy toPath] withParams:[[nearBy toParams] sessionParams] withMethodType:Get andBlock:^(id data, NSError *error) {
            if (data) {
                block(data,nil);
            } else {
                block(nil,error);
            }
        }];
    }
}

#pragma mark - Session
- (void)request_keepAliveWithBlock:(void (^)(id data, NSError *error))block {
    NSDictionary *params = @{@"method":@"user.keepalive"};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:params withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}

#pragma mark - Location
- (void)request_locationWithLat:(double)latitude andLon:(double)lontitude andBlock:(void (^)(id, NSError *))block {
    NSDictionary *params = @{@"method":@"clbs.interestsbyloc",@"longitude":@(lontitude),@"latitude":@(latitude),@"geotype":kGeotype};
    [[NetAPIClient shareJsonClient] requestJsonDataWithPath:@"router" withParams:[params normalParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            block(data,nil);
        } else {
            block(nil,error);
        }
    }];
}
@end
