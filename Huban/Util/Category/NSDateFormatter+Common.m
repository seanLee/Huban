//
//  NSDateFormatter+Common.m
//  Huban
//
//  Created by sean on 15/11/20.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "NSDateFormatter+Common.h"

@implementation NSDateFormatter (Common)
+ (id)dateFormatter
{
    return [[self alloc] init];
}

+ (id)dateFormatterWithFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[self alloc] init];
    dateFormatter.dateFormat = dateFormat;
    return dateFormatter;
}

+ (id)defaultDateFormatter
{
    return [self dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}
@end
