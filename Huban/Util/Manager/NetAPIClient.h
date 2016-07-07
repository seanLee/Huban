//
//  NetAPIClient.h
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AFNetworking.h"
#import "APIUrl.h"

typedef NS_ENUM(NSInteger, NetworkMethod) {
    Get = 0,
    Post,
    Put,
    Delete
};

@interface NetAPIClient : AFHTTPRequestOperationManager
+ (id)shareJsonClient;

- (void)requestJsonDataWithPath:(NSString *)aPath
                    withParams:(NSDictionary *)params
                withMethodType:(NetworkMethod)methodType
                      andBlock:(void (^)(id data,NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)methodType
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id data,NSError *error))block;

- (void)requestJsonDataWithPath:(NSString *)aPath
                           file:(NSDictionary *)file
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)methodType
                       andBlock:(void (^)(id data,NSError *error))block;

- (void)uploadImage:(UIImage *)image path:(NSString *)path name:(NSString *)name
       successBlock:(void (^)(AFHTTPRequestOperation *operation,id responseObject))success
       failureBlock:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure
      progerssBlock:(void (^)(CGFloat progressValue))progress;

- (void)uploadTopicImagesWithPath:(NSString *)aPath
                       withParams:(NSDictionary *)params
                       withImages:(NSArray *)imageArray
                   withMethodType:(NetworkMethod)methodType
                         andBlock:(void (^)(id data,NSError *error))block;

@end
