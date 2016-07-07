//
//  FavoriteTopic.h
//  Huban
//
//  Created by sean on 15/12/13.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteTopic : NSObject
@property (strong, nonatomic) NSNumber *id, *valid;
@property (strong, nonatomic) NSNumber *topicuserrank, *topicusersex;
@property (strong, nonatomic) NSString *topiccode, *topiccontent, *topicimages, *topicusercode, *topicusername, *usercode, *userlogourl, *username, *topicuserage, *topicuserlogourl;
@property (strong, nonatomic) NSDate *createdate;
@end
