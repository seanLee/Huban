//
//  TopicComment.h
//  Huban
//
//  Created by sean on 15/11/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicComment : NSObject
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString *commentcontent, *commentimages, *feedbackcode, *feedbackname, *topiccode, *usercode, *username, *userlogourl, *provcode, *citycode;
@property (strong, nonatomic) NSNumber *longtitude, *latitude;
@property (strong, nonatomic) NSNumber *geotype;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSDate *createdate;

- (instancetype)initWithTopic:(Topic *)topic;

- (NSString *)toPath;

- (NSDictionary *)toCommentParams;
- (NSDictionary *)toDeleteParams;
@end
