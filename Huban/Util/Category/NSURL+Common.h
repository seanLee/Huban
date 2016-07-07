//
//  NSURL+Common.h
//  Huban
//
//  Created by sean on 15/10/11.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Common)
+ (NSURL *)imageURLWithString:(NSString *)url;
+ (NSURL *)thumbImageURLWithString:(NSString *)url;
@end
