//
//  UIBarButtonItem+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/11/5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIBarButtonItem+Common.h"

@implementation UIBarButtonItem (Common)
+ (UIBarButtonItem *)itemWithBtnTitle:(NSString *)title target:(id)obj action:(SEL)selector{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:obj action:selector];
    [buttonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x005f8f"]} forState:UIControlStateDisabled];
    return buttonItem;
}

+ (UIBarButtonItem *)itemWithIcon:(NSString*)iconName target:(id)obj action:(SEL)selector {
    UIButton* button = [[UIButton alloc] init];
    button.imageEdgeInsets = UIEdgeInsetsMake(-2, 0, 0, 0);
    [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:iconName] forState:UIControlStateHighlighted];
    CGSize imgSize = button.imageView.image.size;
    button.size = CGSizeMake(imgSize.width, imgSize.height);
    [button addTarget:obj action:selector forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];;
}

@end
