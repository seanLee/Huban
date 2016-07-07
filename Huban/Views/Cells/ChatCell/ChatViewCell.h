//
//  ChatViewCell.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_ChatViewCell @"ChatViewCell"

#import "ChatViewBasicCell.h"
#import "EMMessage.h"

@interface ChatViewCell : ChatViewBasicCell
@property (copy, nonatomic) void (^didTapCellBlock)();
@property (copy, nonatomic) void (^copyTextBlock)();
@property (copy, nonatomic) void (^deleteBlock)();
@property (copy, nonatomic) void (^transpondBlock)(UIImage *transpondImage);
@end
