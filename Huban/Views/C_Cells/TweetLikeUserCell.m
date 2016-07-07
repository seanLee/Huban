//
//  TweetLikeUserCell.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TweetLikeUserCell.h"
#import "TopicLike.h"

@interface TweetLikeUserCell ()
@property (strong, nonatomic) TopicLike *likeUser;
@property (strong, nonatomic) NSNumber *likes;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *likesLabel;
@end

@implementation TweetLikeUserCell
- (void)configWithUser:(TopicLike *)user likesNum:(NSNumber *)likes{
    self.likeUser = user;
    self.likes = likes;
    
    if (!self.imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.imgView];
    }
    if (_likeUser) {
        [self.imgView sd_setImageWithURL:[NSURL thumbImageURLWithString:_likeUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
        if (_likesLabel) {
            _likesLabel.hidden = YES;
        }
    }else{
        [self.imgView sd_setImageWithURL:nil];
        if (!_likesLabel) {
            _likesLabel = [[UILabel alloc] initWithFrame:_imgView.frame];
            _likesLabel.backgroundColor = [UIColor clearColor];
            _likesLabel.textColor = SYSBACKGROUNDCOLOR_BLUE;
            _likesLabel.font = [UIFont systemFontOfSize:12.f];
            _likesLabel.minimumScaleFactor = 0.5;
            _likesLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_likesLabel];
        }
//        _likesLabel.text = [NSString stringWithFormat:@"%d", _likes.intValue];
        _likesLabel.text = @"更多";
        _likesLabel.hidden = NO;
    }
}
@end
