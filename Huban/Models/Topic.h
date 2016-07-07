//
//  Topic.h
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TopicImage;
@class TopicComments;
@class FavoriteTopic;

@interface Topic : NSObject {
    
}
@property (strong, nonatomic) NSNumber *visibletype, *longitude, *latitude, *geotype, *approvenum, *commentnum, *favoritenum, *complainnum;
@property (strong, nonatomic) NSString *topiccode, *topiccontent, *usercode, *username, *userlogourl, *location, *provcode, *citycode;
@property (strong, nonatomic) NSNumber *userrank, *usersex;
@property (strong, nonatomic) NSString *topicimages;
@property (strong, nonatomic) NSNumber *shield, *favorite, *approve, *valid;
@property (strong, nonatomic) NSDate *updatedate, *createdate;


@property (strong, nonatomic) NSMutableArray *comment_list;
@property (strong, nonatomic) NSMutableArray *likes_users;
@property (strong, nonatomic) NSMutableArray *topicImageArray;
@property (strong, nonatomic) NSMutableArray *selectedAssetURLs;

- (instancetype)initWithFavoriteTopic:(FavoriteTopic *)topic;

- (User *)owner;
- (NSArray *)topicMedium;

- (void)addASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteATweetImage:(TopicImage *)tweetImage;

- (NSInteger)numOfComments;
- (BOOL)hasMoreComments;

- (NSInteger)numbOfLikers;
- (BOOL)hasMoreLikers;

- (NSString *)toPath;

- (NSDictionary *)toQueryParams;
- (NSDictionary *)toDeleteParams;
- (NSDictionary *)toShieldParams;
- (NSDictionary *)toApproveParams;
- (NSDictionary *)toCreateParams;


- (NSString *)imagePath;
- (NSDictionary *)imageParams;
@end

typedef NS_ENUM(NSInteger, TopicImageUploadState)
{
    TopicImageUploadStateInit = 0,
    TopicImageUploadStateIng,
    TopicImageUploadStateSuccess,
    TopicImageUploadStateFail
};

@interface TopicImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSURL *assetURL;
@property (assign, nonatomic) TopicImageUploadState uploadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)topicImageWithAssetURL:(NSURL *)assetURL;
+ (instancetype)topicImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image;
@end
