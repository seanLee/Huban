//
//  Province.h
//  Huban
//
//  Created by sean on 15/11/18.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Province : NSObject
@property (strong, nonatomic) NSNumber *latitude, *longitude, *valid;
@property (strong, nonatomic) NSString *provcode, *provfull, *provmemo, *provname;


@property (strong, nonatomic)NSMutableArray *subRegionArray;
@end
