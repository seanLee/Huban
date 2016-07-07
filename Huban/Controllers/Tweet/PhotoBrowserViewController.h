//
//  PhotoBrowserViewController.h
//  Huban
//
//  Created by sean on 15/9/23.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"
#import "MJPhoto.h"

@interface PhotoBrowserViewController : BaseViewController
@property (strong, nonatomic) NSMutableArray *photos;
@property (assign, nonatomic) NSInteger currentIndex;

@property (copy, nonatomic) void (^deleteImageBlock)(NSMutableArray *assetsArray);
@end
