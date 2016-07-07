//
//  UITapImageView.h
//  Huban
//
//  Created by sean on 15/7/24.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapImageView : UIImageView
- (void)addTapBlock:(void(^)(id))tapAction;

- (void)setImageWithURL:(NSURL *)imgUrl
       placeholderImage:(UIImage *)placeholderImage
               tapBlock:(void(^)(id obj))tapAction;
@end
