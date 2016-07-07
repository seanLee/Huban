//
//  DropDownMenu.h
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropDownMenu : UIView
@property (strong, nonatomic) NSArray *dataItem;
@property (copy, nonatomic) void (^cancleBlock)(DropDownMenu *menu);
@property (copy, nonatomic) void (^clickedIndexBlock)(NSInteger curIndex);

- (void)hide;
- (void)showInView:(UIView *)aView;;
@end

#define kCellIdentifier_DropDownMenuCell @"DropDownMenuCell"

@interface DropDownMenuCell : UITableViewCell
- (void)setTextStr:(NSString *)textStr;

+ (CGFloat)cellHeight;
@end
