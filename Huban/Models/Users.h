//
//  Users.h
//  Huban
//
//  Created by sean on 15/10/15.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Users : NSObject
@property (strong, nonatomic) NSString *queryText;
@property (assign, nonatomic) NSInteger start, limit, count;
@property (strong, nonatomic) NSMutableArray *list;

- (NSString *)toPath;

- (NSDictionary *)toSearchParams;
@end
