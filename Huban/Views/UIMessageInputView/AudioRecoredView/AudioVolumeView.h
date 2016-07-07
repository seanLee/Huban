//
//  AudioVolumeView.h
//  Huban
//
//  Created by sean on 15/9/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioVolumeView : UIView

- (void)animatedWithVolume:(double)volume;
- (void)clearVolume;
@end
