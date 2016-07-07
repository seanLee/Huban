//
//  AudioVolumeView.m
//  Huban
//
//  Created by sean on 15/9/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAudioVolumeViewVolumeHeight 3.0f
#define kAudioVolumeViewVolumeMinWidth 12.f
#define kAudioVolumeViewVolumeMaxWidth 24.f
#define kAudioVolumeViewVolumePadding 3.f
#define kAudioVolumeViewVolumeNumber 10

#import "AudioVolumeView.h"

@interface AudioVolumeView ()
@property (strong, nonatomic) NSMutableArray *volumeViews;
@property (strong, nonatomic) NSMutableArray *volumes;
@property (strong, nonatomic) NSTimer *animationTimer;

@property (assign, nonatomic) NSInteger count;
@property (assign, nonatomic) BOOL isAnimating;
@end

@implementation AudioVolumeView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _volumes = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
        _volumeViews = [[NSMutableArray alloc] initWithCapacity:kAudioVolumeViewVolumeNumber];
        
        CGFloat fullWidth = self.frame.size.width;
        CGFloat originY = 3.f; //底部与麦克风icon对齐
        
        for (int i = 0; i < kAudioVolumeViewVolumeNumber; i++) {
            [_volumes addObject:@0];
            
            CGFloat curWidth = fullWidth - ((kAudioVolumeViewVolumeMaxWidth - kAudioVolumeViewVolumeMinWidth) / kAudioVolumeViewVolumeNumber * i);
            UIView *volumeView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, curWidth, kAudioVolumeViewVolumeHeight)];
            volumeView.backgroundColor = [UIColor whiteColor];
            [self addSubview:volumeView];
            [_volumeViews addObject:volumeView];
            originY += (kAudioVolumeViewVolumeHeight + kAudioVolumeViewVolumePadding);
        }
        [self resetState];
    }
    return self;
}

- (void)startAnimationWithVolume:(NSInteger)maxVolume {
    UIView *volumeView = [_volumeViews objectAtIndex:(_volumeViews.count - _count - 1)];
    volumeView.hidden = NO;
    if (++_count >= maxVolume) {
        [self resetState];
        [_animationTimer invalidate];
        _isAnimating = NO;
    }
}

- (void)animatedWithVolume:(double)volume {
    if (_isAnimating) {
        return;
    }
     _isAnimating = YES;
    __weak typeof(self) weakSelf = self;
    NSInteger maxVolume = MIN(10, MAX(2, volume/0.1)); //当用户录制语音时,最小显示两格,最多显示十格音量
    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:.1f block:^{
        [weakSelf startAnimationWithVolume:maxVolume];
    } repeats:YES];
}

- (void)resetState {
    //重置当前显示
    _count = 0;
    
    for (UIView *curItem in _volumeViews) {
        curItem.hidden = YES;
    }
    //显示最下面一个
    UIView *indicatorVolumeView = [_volumeViews lastObject];
    indicatorVolumeView.hidden = NO;
}

- (void)clearVolume {
    [_volumes removeAllObjects];
    for (int i = 0; i < _volumeViews.count ; i++) {
        [_volumes addObject:@0];
    }
    [self resetState];
}
@end
