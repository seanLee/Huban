//
//  NSString+Common.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Emojize.h"

@interface NSString (Common)
+ (NSString *)userAgentStr;

- (NSString *)URLEncoding;
- (NSString *)URLDecoding;
- (NSString *)md5Str;
- (NSString *)sha1Str;
- (NSURL *)urlWithCodePath;
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width;
- (NSURL *)urlImageWithCodePathResize:(CGFloat)width crop:(BOOL)needCrop;
- (NSURL *)urlImageWithCodePathResizeToView:(UIView *)view;

- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
-(BOOL)containsEmoji;

- (NSString *)emotionMonkeyName;

+ (NSString *)sizeDisplayWithByte:(CGFloat)sizeOfByte;

- (NSString *)trimWhitespace;
- (BOOL)isEmpty;
- (BOOL)isEmptyOrListening;
//判断是否为整形
- (BOOL)isPureInt;
//判断是否为浮点形
- (BOOL)isPureFloat;
- (BOOL)isPhoneNumber;

- (NSRange)rangeByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSRange)rangeByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

- (NSString *)stringByTrimmingLeftCharactersInSet:(NSCharacterSet *)characterSet;
- (NSString *)stringByTrimmingRightCharactersInSet:(NSCharacterSet *)characterSet;

//是否包含汉字
- (BOOL)containChinese;
//转换拼音
- (NSString *)transformToPinyin;

//是否包含语音解析的图标
- (BOOL)hasListenChar;
@end