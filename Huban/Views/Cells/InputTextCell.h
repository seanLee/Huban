//
//  InputTextCell.h
//  Huban
//
//  Created by sean on 15/8/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef void (^inputTextChangeBlock)(NSString *);

#define kCellIdentifier_InputTextCell @"InputTextCell"

#import <UIKit/UIKit.h>

@interface InputTextCell : UITableViewCell
@property (copy, nonatomic) inputTextChangeBlock inputBlock;
@property (copy, nonatomic) void (^captchaClicked)();
@property (assign, nonatomic) BOOL isSecret;
@property (assign, nonatomic) BOOL topRounded;
@property (assign, nonatomic) BOOL bottomRounded;
@property (assign, nonatomic) BOOL showCaptchaButton;

@property (strong, nonatomic) UIButton *captchaButton;

- (void)setTitleStr:(NSString *)title andPlaceholderStr:(NSString *)placeholder;

+ (CGFloat)cellHeight;
@end
