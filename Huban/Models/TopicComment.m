//
//  TopicComment.m
//  Huban
//
//  Created by sean on 15/11/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "TopicComment.h"

@implementation TopicComment
- (instancetype)initWithTopic:(Topic *)topic {
    self = [super init];
    if (self) {
        self.provcode = topic.provcode;
        self.citycode = topic.citycode;
        self.latitude = topic.latitude;
        self.longtitude = topic.longitude;
        self.geotype = topic.geotype;
        self.location = topic.location;
        self.topiccode = topic.topiccode;
    }
    return self;
}

- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)toCommentParams {
    return @{@"method":@"topic.comment.create",@"commentcontent":self.commentcontent,@"commentimages":self.commentimages.length > 0?self.commentimages:@"",@"feedbackcode":self.feedbackcode.length>0?self.feedbackcode:@"",
             @"provcode":self.provcode,@"citycode":self.citycode,@"longtitude":self.longtitude,@"latitude":self.latitude,@"geotype":self.geotype,@"location":self.location,@"topiccode":self.topiccode};
}
- (NSDictionary *)toDeleteParams {
    return @{@"method":@"topic.comment.delete",@"topiccode":self.topiccode,@"id":self.id};
}
@end
