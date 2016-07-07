//
//  UIMessageInputView_Add.h
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Add : UIView
@property (copy, nonatomic) void(^addIndexBlock)(NSInteger);
@end

#define kCellIdentifier_UIMessageInputView_Add_CCell @"UIMessageInputView_Add_CCell"

@interface UIMessageInputView_Add_CCell : UICollectionViewCell
- (void)setTextStr:(NSString *)textStr andIconStr:(NSString *)iconStr;

+ (CGSize)cellSize;
@end
