//
//  NSURL+Common.m
//  Huban
//
//  Created by sean on 15/10/11.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "NSURL+Common.h"

@implementation NSURL (Common)
+ (NSURL *)imageURLWithString:(NSString *)url {
    NSString *rootURL = [[NSUserDefaults standardUserDefaults] objectForKey:kImaget_Root];
    NSString *imageURL = [NSString stringWithFormat:@"%@%@",rootURL,url];
    return [NSURL URLWithString:imageURL];
}

+ (NSURL *)thumbImageURLWithString:(NSString *)url {
    NSString *imageURL = [NSString stringWithFormat:@"http://rest.qianzhenkeji.com/mop/file?filename=%@@%@",url,@"!min"];
    return [NSURL URLWithString:imageURL];
}
@end
