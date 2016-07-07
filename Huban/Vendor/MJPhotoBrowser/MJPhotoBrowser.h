//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import "MJPhoto.h"

@protocol MJPhotoBrowserDelegate;
@interface MJPhotoBrowser : UIView <UIScrollViewDelegate>
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 保存按钮
@property (nonatomic, assign) NSUInteger showSaveBtn;
// 点击图片
@property (nonatomic, copy) void (^tapPhotoBlock)();

//是否显示转发
@property (assign, nonatomic) BOOL showTranspondAction;
//转发
@property (nonatomic, copy) void (^transpondBlock)(UIImage *tanspondImage);
// 显示
- (void)show;
@end