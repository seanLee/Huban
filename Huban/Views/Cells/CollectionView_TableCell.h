//
//  CollectionView_TableCell.h
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_CollectionView_TableCell @"CollectionView_TableCell"

#import <UIKit/UIKit.h>

@interface CollectionView_TableCell : UITableViewCell
+ (CGFloat)cellHeight;
@end

#define kCellIdentifier_AddUserTypeCCell @"AddUserTypeCCell"
@interface AddUserTypeCCell : UICollectionViewCell
- (void)setTextStr:(NSString *)str andIcon:(NSString *)imageStr;
@end