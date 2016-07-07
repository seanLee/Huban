//
//  Region.h
//  Huban
//
//  Created by sean on 15/11/18.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Region : NSObject
@property (strong, nonatomic) NSNumber *latitude, *longtitude, *valid, *cityarea, *citypopulation;
@property (strong, nonatomic) NSString *citycode, *cityfull, *citylevel, *citymemo, *cityname, *cityphonecode, *citypostcode, *provcode;
@end
