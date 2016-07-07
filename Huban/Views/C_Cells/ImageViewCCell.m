//
//  ImageViewCCell.m
//  Ibeauty
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ImageViewCCell.h"

@interface ImageViewCCell ()
@end

@implementation ImageViewCCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_imageView) {
            _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            _imageView.clipsToBounds = YES;
            [self.contentView addSubview:_imageView];
        }
    }
    return self;
}

- (void)setCurImageUrl:(NSURL *)curImageUrl {
    _curImageUrl = curImageUrl;
    if (!_curImageUrl || _curImageUrl.absoluteString.length == 0) {
        return;
    }
     [_imageView sd_setImageWithURL:_curImageUrl placeholderImage:[UIImage avatarPlacer]];
}

- (void)setCurImage:(UIImage *)curImage {
    _curImage = curImage;
    if (!_curImage) {
        return;
    }
    [_imageView setImage:curImage];
}

- (void)setCurTopicImage:(TopicImage *)curTopicImage {
    _curTopicImage = curTopicImage;
    if (!_curTopicImage) {
        return;
    }
    RAC(self.imageView, image) = [RACObserve(self.curTopicImage, thumbnailImage) takeUntil:self.rac_prepareForReuseSignal];
}
@end
