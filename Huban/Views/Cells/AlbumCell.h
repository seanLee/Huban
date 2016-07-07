//
//  AlbumCell.h
//  Huban
//
//  Created by sean on 15/9/4.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_AlbumCell @"AlbumCell"
#define kCellIdentifier_AlbumCellWithImages @"AlbumCellWithImages"

#import <UIKit/UIKit.h>

@interface AlbumCell : UITableViewCell
@property (strong, nonatomic) Topic *curTopic;

+ (CGFloat)cellHeigthWithObj:(id)obj;
@end
