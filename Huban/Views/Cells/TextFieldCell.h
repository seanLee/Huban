//
//  TextFieldCell.h
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_TextFieldCell @"TextFieldCell"

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell
@property (assign, nonatomic) BOOL isSecret;
@property (copy, nonatomic) void (^textChangedBlock)(NSString *inputStr);

- (void)setPlacerStr:(NSString *)placerStr;

+ (CGFloat)cellHeight;
@end
