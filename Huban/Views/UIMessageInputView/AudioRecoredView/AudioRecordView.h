//
//  AudioRecordView.h
//  Huban
//
//  Created by sean on 15/9/11.
//  Copyright (c) 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, AudioRecordViewState) {
    AudioRecoredViewStateNomal,
    AudioRecoredViewStateCancel
};

#import <UIKit/UIKit.h>

@protocol AudioRecordViewDelegate;

@interface AudioRecordView : UIView
@property (copy, nonatomic) void (^didFinishRecording)(NSString *file,NSTimeInterval duration);
@property (assign, nonatomic) BOOL isRecording;
@property (assign, nonatomic) AudioRecordViewState recordState;

+ (instancetype)audioRecoredView;

// 录音按钮按下
-(void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)recordButtonDragInside;
// 手指移动到录音按钮外部
-(void)recordButtonDragOutside;
@end
