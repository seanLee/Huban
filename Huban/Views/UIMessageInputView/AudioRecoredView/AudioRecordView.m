//
//  AudioRecordView.m
//  Huban
//
//  Created by sean on 15/9/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAudioRecoredView_Width 130.f
#define kAudioRecoredView_MicroPhoneSize CGSizeMake(44.f, 60.f)
#define kAudioRecoredView_TopMargin 30.f
#define kAudioRecoredView_VolumeWidth 24.f
#define kAudioRecoredView_LabelHeight 16.f

#import "AudioRecordView.h"
#import "AudioVolumeView.h"
#import "EMCDDeviceManager.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioRecordView ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) AudioVolumeView *volumeView;

@property (strong, nonatomic) NSTimer *volumeTimer;
@end

@implementation AudioRecordView
+ (instancetype)audioRecoredView {
    AudioRecordView *view = [[AudioRecordView alloc] initWithFrame:CGRectMake(0, 0, kAudioRecoredView_Width, kAudioRecoredView_Width)];
    view.center = kKeyWindow.center;
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isRecording = NO;
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        //imageView
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAudioRecoredView_MicroPhoneSize.width, kAudioRecoredView_MicroPhoneSize.height)];
        _imgView.image = [UIImage imageNamed:@"icon_microphone"];
        [self addSubview:_imgView];
        
        //volumeView
        _volumeView = [[AudioVolumeView alloc] initWithFrame:CGRectMake(0, 0, kAudioRecoredView_VolumeWidth, kAudioRecoredView_MicroPhoneSize.height)];
        [self addSubview:_volumeView];
        
        //label
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kAudioRecoredView_Width, kAudioRecoredView_LabelHeight)];
        _infoLabel.font = [UIFont boldSystemFontOfSize:13.f];
        _infoLabel.textColor = [UIColor whiteColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.layer.cornerRadius = 2.f;
        _infoLabel.layer.masksToBounds = YES;
        _infoLabel.text = @"手指上滑,取消发送";
        [self addSubview:_infoLabel];
        
        //relocation
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kAudioRecoredView_TopMargin);
            make.left.equalTo(self).offset(kAudioRecoredView_TopMargin);
            make.width.mas_equalTo(kAudioRecoredView_MicroPhoneSize.width);
            make.height.mas_equalTo(kAudioRecoredView_MicroPhoneSize.height);
        }];
        
        [_volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView);
            make.height.equalTo(_imgView);
            make.left.equalTo(_imgView.mas_right).offset(kPaddingLeftWidth/2);
            make.width.mas_equalTo(kAudioRecoredView_VolumeWidth);
        }];
        
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imgView.mas_bottom).offset(kPaddingLeftWidth);
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self).offset(-5);
            make.height.mas_equalTo(kAudioRecoredView_LabelHeight);
        }];
    }
    return self;
}

- (void)setRecordState:(AudioRecordViewState)recordState {
    if (_recordState != recordState) {
        _recordState = recordState;
        [self checkOutState];
    }
}

- (void)checkOutState {
    if (_recordState == AudioRecoredViewStateNomal) {
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.text = @"手指上滑,取消发送";
    } else if (_recordState == AudioRecoredViewStateCancel) {
        _infoLabel.backgroundColor = [UIColor colorWithHexString:@"0x8a2729"];
        _infoLabel.text = @"松开手指,取消发送";
    }
}

#pragma mark - Private Method
- (void)record {
    if ([self _canRecord]) {
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        //开始录音
        @weakify(self);
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
            @strongify(self);
            if (!error) {
                [self startTimer];
            }
        }];
    }
}

- (void)stop {
    _isRecording = NO;
    [self.volumeView clearVolume];
    [self stopTimer];
    //停止录音
    @weakify(self);
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        @strongify(self);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showHudTipStr:@"录音时间太短"];
            });
        } else { //如果正常录音
            if (self.didFinishRecording) {
                self.didFinishRecording(recordPath,aDuration);
            }
        }
    }];
}

- (void)cancel {
    _isRecording = NO;
    [self.volumeView clearVolume];
    [self stopTimer];
    //取消录音
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

- (void)startTimer {
    @weakify(self);
    _volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 block:^{
        @strongify(self);
        [self getVolumeAnimation];
    } repeats:YES];
}

- (void)stopTimer {
    [_volumeTimer invalidate];
    _volumeTimer = nil;
}

- (void)getVolumeAnimation {
    double voiceSound = 0;
    voiceSound = [[EMCDDeviceManager sharedInstance] emPeekRecorderVoiceMeter];
    [_volumeView animatedWithVolume:voiceSound];
}
#pragma mark - Action
- (void)recordButtonTouchDown {
    self.recordState = AudioRecoredViewStateNomal;
    [kKeyWindow addSubview:self];
    //start record
    [self record];
}

-(void)recordButtonTouchUpInside {
    [self stop];
    [self removeFromSuperview];
}

-(void)recordButtonTouchUpOutside {
    [self cancel];
    [self removeFromSuperview];
}

-(void)recordButtonDragInside {
    self.recordState =  AudioRecoredViewStateNomal;
}


-(void)recordButtonDragOutside {
    self.recordState =  AudioRecoredViewStateCancel;
}

#pragma mark - Private Method
- (BOOL)_canRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}
@end
