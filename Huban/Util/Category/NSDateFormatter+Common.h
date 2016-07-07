//
//  NSDateFormatter+Common.h
//  Huban
//
//  Created by sean on 15/11/20.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Common)
+ (id)dateFormatter;

+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

+ (id)defaultDateFormatter;/*yyyy-MM-dd HH:mm:ss*/
@end
