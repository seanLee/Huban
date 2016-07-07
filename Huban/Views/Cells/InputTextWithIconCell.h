//
//  InputTextWithIconCell.h
//  Huban
//
//  Created by sean on 15/7/30.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_InputTextWithIconCell @"InputTextWithIconCell"

#import <UIKit/UIKit.h>

@interface InputTextWithIconCell : UITableViewCell
@property (strong, nonatomic) UIImage *iconImage;
@property (strong, nonatomic) NSString *placeholderStr;
@property (strong, nonatomic) NSString *lastLoginCode;
@property (assign, nonatomic) BOOL isSecret;
@property (assign, nonatomic) BOOL topRounded;
@property (assign, nonatomic) BOOL bottomRounded;

@property (copy, nonatomic) void(^textValueChangedBlock)(NSString *str);
@property (copy, nonatomic) void(^textDidEndEditingBlock)(NSString *str);

+ (CGFloat)cellHeight;
@end
