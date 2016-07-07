//
//  Topic.m
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Topic.h"
#import "FavoriteTopic.h"

@interface Topic ()
@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) NSMutableArray *imageArray;
@end

@implementation Topic
- (instancetype)initWithFavoriteTopic:(FavoriteTopic *)topic {
    self = [super init];
    if (self) {
        self.createdate = topic.createdate;
        self.topiccode = topic.topiccode;
        self.topiccontent = topic.topiccontent;
        self.topicimages = topic.topicimages;
        self.usercode = topic.topicusercode;
        self.userlogourl = topic.topicuserlogourl;
        self.username = topic.topicusername;
        self.userrank = topic.topicuserrank;
        self.usersex = topic.topicusersex;
        self.valid = topic.valid;
    }
    return self;
}

#pragma mark - Getter
- (NSMutableArray *)topicImageArray {
    if (!_topicImageArray) {
        _topicImageArray = [NSMutableArray new];
    }
    return _topicImageArray;
}

- (NSMutableArray *)comment_list {
    if (!_comment_list) {
        _comment_list = [NSMutableArray new];
    }
    return _comment_list;
}

- (NSMutableArray *)likes_users {
    if (!_likes_users) {
        _likes_users = [NSMutableArray new];
    }
    return _likes_users;
}

- (NSString *)location {
    if (!_location) {
        _location = @"";
    }
    return _location;
}

- (NSString *)topiccontent {
    if (!_topiccontent) {
        _topiccontent = @"";
    }
    return _topiccontent;
}

- (NSInteger)numOfComments {
    return MIN(_comment_list.count + 1, MIN(_commentnum.intValue, 6));
}
- (BOOL)hasMoreComments {
    return (_commentnum.intValue > _comment_list.count || _commentnum.intValue > 5);
}

- (NSInteger)numbOfLikers {
    return MIN(_likes_users.count + 1, MIN(_approvenum.intValue, [self maxLikerNum]));
}
- (BOOL)hasMoreLikers {
    return (_approvenum.intValue > _likes_users.count || _approvenum.intValue > [self maxLikerNum] - 1);
}
- (NSInteger)maxLikerNum {
    NSInteger maxNum = 16;
    return maxNum;
}

#pragma mark - User
- (User *)owner {
    if (!_curUser) {
        _curUser = [[User alloc] init];
        _curUser.userlogourl = _userlogourl;
        _curUser.username = _username;
        _curUser.usercode = _usercode;
        _curUser.usersex = _usersex;
        _curUser.userrank = _userrank;
    }
    return _curUser;
}

#pragma mark - TopicImageArray
- (NSArray *)topicMedium {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
        
        if (_topicimages && ![_topicimages isEmpty]) {
            NSArray *imageArray = [_topicimages componentsSeparatedByString:@","];
            for (NSString *subPath in imageArray) {
                [_imageArray addObject:[NSURL thumbImageURLWithString:subPath]];
            }
        }
    }
    return _imageArray;
}

#pragma mark - ALAsset
- (void)setSelectedAssetURLs:(NSMutableArray *)selectedAssetURLs{
    NSMutableArray *needToAdd = [NSMutableArray new];
    NSMutableArray *needToDelete = [NSMutableArray new];
    [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![selectedAssetURLs containsObject:obj]) {
            [needToDelete addObject:obj];
        }
    }];
    [needToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteASelectedAssetURL:obj];
    }];
    [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.selectedAssetURLs containsObject:obj]) {
            [needToAdd addObject:obj];
        }
    }];
    [needToAdd enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addASelectedAssetURL:obj];
    }];
}

- (void)addASelectedAssetURL:(NSURL *)assetURL{
    if (!_selectedAssetURLs) {
        _selectedAssetURLs = [NSMutableArray new];
    }
    if (!_topicImageArray) {
        _topicImageArray = [NSMutableArray new];
    }
    
    [_selectedAssetURLs addObject:assetURL];
    
    NSMutableArray *curTweetImages = [self mutableArrayValueForKey:@"topicImageArray"];//为了kvo
    TopicImage *tweetImg = [TopicImage topicImageWithAssetURL:assetURL];
    [curTweetImages addObject:tweetImg];
}

- (void)deleteASelectedAssetURL:(NSURL *)assetURL{
    [self.selectedAssetURLs removeObject:assetURL];
    NSMutableArray *curTweetImages = [self mutableArrayValueForKey:@"topicImageArray"];//为了kvo
    [curTweetImages enumerateObjectsUsingBlock:^(TopicImage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.assetURL == assetURL) {
            [curTweetImages removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)deleteATweetImage:(TopicImage *)topicImage{
    NSMutableArray *curTweetImages = [self mutableArrayValueForKey:@"topicImageArray"];//为了kvo
    [curTweetImages removeObject:topicImage];
    if (topicImage.assetURL) {
        [self.selectedAssetURLs removeObject:topicImage.assetURL];
    }
}

- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toQueryParams {
    return @{@"method":@"topic.query",@"topiccode":_topiccode};
}

- (NSDictionary *)toDeleteParams {
    return @{@"method":@"topic.delete",@"topiccode":_topiccode};
}
- (NSDictionary *)toShieldParams {
    return @{@"method":@"topic.shield.create",@"topiccode":_topiccode};
}
- (NSDictionary *)toApproveParams {
    return @{@"method":_approve.boolValue?@"topic.approve.delete":@"topic.approve.create",@"topiccode":_topiccode};
}
- (NSDictionary *)toCreateParams {
    return @{@"method":@"topic.create",@"topiccontent":_topiccontent?:@"",@"visibletype":_visibletype,
             @"provcode":_provcode?:@"",@"citycode":_citycode?:@"",@"topicimages":_topicimages?:@"",
             @"longitude":@0,@"latitude":@0,@"location":@"",@"geotype":kGeotype};
}

- (NSString *)imagePath {
    return @"file";
}
- (NSDictionary *)imageParams {
    return @{@"filetype":@2};
}
@end

@implementation TopicImage
+ (instancetype)topicImageWithAssetURL:(NSURL *)assetURL {
    TopicImage *topicImage = [[TopicImage alloc] init];
    topicImage.uploadState = TopicImageUploadStateInit;
    topicImage.assetURL = assetURL;
    
    void(^selectedAsset)(ALAsset *) = ^(ALAsset *asset) {
        if (asset) {
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:asset];
            UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                topicImage.image = highQualityImage;
                topicImage.thumbnailImage = thumbnailImage;
            });
        }
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    @weakify(assetsLibrary);
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            selectedAsset(asset);
        } else {
            @strongify(assetsLibrary)
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopG) {
                    if ([result.defaultRepresentation.url isEqual:assetURL]) {
                        selectedAsset(result);
                        *stop = YES;
                        *stopG = YES;
                    }
                }];
            } failureBlock:^(NSError *error) {
                [self showHudTipStr:@"读取图片失败"];
            }];
        }
    } failureBlock:^(NSError *error) {
        [self showHudTipStr:@"读取图片失败"];
    }];
    
    return topicImage;
}

+ (instancetype)topicImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image {
    TopicImage *topicImage = [[TopicImage alloc] init];
    topicImage.uploadState = TopicImageUploadStateInit;
    topicImage.assetURL = assetURL;
    topicImage.image = image;
    topicImage.thumbnailImage = [image scaledToSize:CGSizeMake(kScaleFrom_iPhone5_Desgin(70), kScaleFrom_iPhone5_Desgin(70)) highQuality:YES];
    return topicImage;
}

@end
