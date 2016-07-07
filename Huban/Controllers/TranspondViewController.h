//
//  TranspondViewController.h
//  Huban
//
//  Created by sean on 15/12/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BaseViewController.h"

@interface TranspondViewController : BaseViewController
@property (copy, nonatomic) void (^selectedItemsBlock)(NSArray *selectedItems);
@end
