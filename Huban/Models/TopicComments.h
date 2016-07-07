//
//  TopicComments.h
//  Huban
//
//  Created by sean on 15/11/8.
//  Copyright © 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger,CommentType) {
    CommentType_CityCircle = 0,
    CommentType_Normal
};

#import <Foundation/Foundation.h>
#import "TopicComment.h"

@interface TopicComments : NSObject
@property (strong, nonatomic) NSString *topicCode;
@property (strong, nonatomic) NSMutableArray *list;
@property (assign, nonatomic) CommentType commentType;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) NSInteger curPage;

- (NSString *)toPath;

- (NSDictionary *)toCommentsParams;

- (void)configWithComments:(NSDictionary *)dataList;
@end
