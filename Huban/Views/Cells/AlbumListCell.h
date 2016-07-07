//
//  AlbumCell.h
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_AlbumListCell_Index @"AlbumListCell_Index"
#define kCellIdentifier_AlbumListCell @"kCellIdentifier_AlbumListCell"

#import <UIKit/UIKit.h>

@interface AlbumListCell : UITableViewCell
@property (strong, nonatomic) NSArray *topics;
@property (copy, nonatomic) void (^addPhotoBlock)();
@property (copy, nonatomic) void (^itemSelectedBlock)(Topic *curTopic);

+ (CGFloat)cellHeightWidhObj:(id)obj isIndex:(BOOL)index;
@end
