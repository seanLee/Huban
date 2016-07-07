//
//  NetAPIClient.m
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "NetAPIClient.h"
#import "Login.h"

@implementation NetAPIClient
+ (id)shareJsonClient {
    static NetAPIClient *_shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareClient = [[NetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kNetPath_Code_Base]];
    });
    return _shareClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)methodType
                       andBlock:(void (^)(id, NSError *))block {
    [self requestJsonDataWithPath:aPath withParams:params withMethodType:methodType autoShowError:YES andBlock:block];
}

- (void)requestJsonDataWithPath:(NSString *)aPath
                     withParams:(NSDictionary *)params
                 withMethodType:(NetworkMethod)methodType
                  autoShowError:(BOOL)autoShowError
                       andBlock:(void (^)(id, NSError *))block {
    if (!aPath || aPath.length == 0) {
        return;
    }
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //发起请求
    switch (methodType) {
        case Get: {
            [self GET:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil,error);
                } else {
                    block(responseObject,nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                !autoShowError || [self showError:error];
                block(nil,error);
            }];
        }
            break;
        case Post:{
            [self POST:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                !autoShowError || [self showError:error];
                block(nil, error);
            }];
        }
            break;
        case Put: {
            [self PUT:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                !autoShowError || [self showError:error];
                block(nil, error);
            }];
        }
            break;
        case Delete: {
            [self DELETE:aPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:responseObject autoShowError:autoShowError];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                !autoShowError || [self showError:error];
                block(nil, error);
            }];
        }
            break;
    }
}

- (void)requestJsonDataWithPath:(NSString *)aPath file:(NSDictionary *)file withParams:(NSDictionary *)params withMethodType:(NetworkMethod)methodType andBlock:(void (^)(id, NSError *))block {
    aPath = [aPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //Data
    NSData *data;
    NSString *name, *fileName;
    
    if (file) {
        UIImage *image = file[@"image"];
        //压缩
        data = UIImageJPEGRepresentation(image, 1.0);
        if ((float)data.length/1024 > 1000) {
            data = UIImageJPEGRepresentation(image, 1024*1000/(float)data.length);
        }
        name = file[@"name"];
        fileName = file[@"fileName"];
    }
    
    switch (methodType) {
        case Post: {
            AFHTTPRequestOperation *operation = [self POST:aPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                if (file) {
                    [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
                }
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                id error = [self handleResponse:responseObject];
                if (error) {
                    block(nil, error);
                }else{
                    block(responseObject, nil);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self showError:error];
                block(nil, error);
            }];
            [operation start];
        }
            break;
            
        default:
            break;
    }
}

- (void)uploadImage:(UIImage *)image path:(NSString *)path name:(NSString *)name successBlock:(void (^)(AFHTTPRequestOperation *, id))success failureBlock:(void (^)(AFHTTPRequestOperation *, NSError *))failure progerssBlock:(void (^)(CGFloat))progress {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if ((float)data.length/1024 > 1000) {
        data = UIImageJPEGRepresentation(image, 1024*1000.0/(float)data.length);
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg",[Login curLoginUser].useruid, str];
    
     AFHTTPRequestOperation *operation = [self POST:path parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:data name:name fileName:fileName mimeType:@"image/jpeg"];
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         id error = [self handleResponse:responseObject];
         if (error && failure) {
             failure(operation, error);
         } else {
             success(operation, responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
             failure(operation, error);
         }
     }];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        CGFloat progressValue = (float)totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progress) {
            progress(progressValue);
        }
    }];
}

- (void)uploadTopicImagesWithPath:(NSString *)aPath withParams:(NSDictionary *)params withImages:(NSArray *)imageArray withMethodType:(NetworkMethod)methodType andBlock:(void (^)(id, NSError *))block {
    [self.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] objectForKey:kSession] forHTTPHeaderField:@"session"];
    [self POST:aPath parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMdd_hh_mm_ssss"];
        NSString *dateString = [formatter stringFromDate:date];
        //添加图片
        for (int i = 0; i < imageArray.count; i++) {
            UIImage *image = imageArray[i];
            NSString *fileName = [NSString stringWithFormat:@"%@%@.png",dateString,@(i)];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            [formData appendPartWithFileData:imageData name:fileName fileName:fileName mimeType:@"image/jpg/png/jpeg"];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        } else {
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        block(nil,error);
        }];
}
@end
