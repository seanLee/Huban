//
//  TopicLike.h
//  Huban
//
//  Created by sean on 15/11/26.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicLike : NSObject
@property (strong, nonatomic) NSString *topiccode, *usercode, *userlogourl, *username;
@property (strong, nonatomic) NSNumber *id, *valid;
@property (strong, nonatomic) NSDate *createdate;
@end
