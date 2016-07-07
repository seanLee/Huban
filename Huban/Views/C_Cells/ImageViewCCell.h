//
//  ImageViewCCell.h
//  Ibeauty
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellIdentifier_IamgeCCell @"Image_CCell"

#import <UIKit/UIKit.h>

@interface ImageViewCCell : UICollectionViewCell
@property (strong, nonatomic) NSURL *curImageUrl;
@property (strong, nonatomic) UIImage *curImage;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) TopicImage *curTopicImage;
@end
