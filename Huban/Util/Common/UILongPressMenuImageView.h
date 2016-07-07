//
//  UILongPressMenuImageView.h
//  Huban
//
//  Created by sean on 15/9/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILongPressMenuImageView : UIImageView
@property (strong, nonatomic) NSArray *longPressTitle;
@property (copy, nonatomic) void (^longPressMenuBlock)(NSInteger index, NSString *title);

- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block;
@end
