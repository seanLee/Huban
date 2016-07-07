//
//  CommentNotification.h
//  Huban
//
//  Created by sean on 15/11/9.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentNotification : NSObject
@property (strong, nonatomic) NSString *holdercode;
@property (strong, nonatomic) NSString *topiccode, *username, *usercode, *noticontent;
@property (strong, nonatomic) NSNumber *id, *readstatus;
@end
