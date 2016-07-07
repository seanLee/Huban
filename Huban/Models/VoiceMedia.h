//
//  VoiceMedia.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceMedia : NSObject
@property (strong, nonatomic) NSString *file;
@property (assign, nonatomic) NSTimeInterval duration;
@end
