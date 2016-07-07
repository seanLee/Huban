/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EaseMessageReadManager.h"
#import "EMCDDeviceManager.h"

static EaseMessageReadManager *detailInstance = nil;

@interface EaseMessageReadManager()

@property (strong, nonatomic) UIWindow *keyWindow;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) UINavigationController *photoNavigationController;

@property (strong, nonatomic) UIAlertView *textAlertView;

@end

@implementation EaseMessageReadManager

+ (id)defaultManager
{
    @synchronized(self){
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            detailInstance = [[self alloc] init];
        });
    }
    
    return detailInstance;
}

#pragma mark - getter

- (UIWindow *)keyWindow
{
    if(_keyWindow == nil)
    {
        _keyWindow = [[UIApplication sharedApplication] keyWindow];
    }
    
    return _keyWindow;
}


#pragma mark - public
- (void)showBrowserWithImages:(NSArray *)imageArray withTranspondBlock:(void (^)(UIImage *))transpondBlock {
    if (imageArray && imageArray.count) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id obj in imageArray) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            if ([obj isKindOfClass:[UIImage class]]) {
                photo.image = obj;
            } else if ([obj isKindOfClass:[NSURL class]]) {
                photo.url = obj;
            }
            [photoArray addObject:photo];
        }
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.transpondBlock = transpondBlock;
        browser.showSaveBtn = NO;
        browser.showTranspondAction = YES;
        browser.currentPhotoIndex = 0; // 弹出相册时显示的第一张图片是？
        browser.photos = photoArray; // 设置所有的图片
        [browser show];
    }
}

- (BOOL)prepareMessageAudioModel:(EaseMessageModel *)messageModel
                      updateViewCompletion:(void (^)(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel))updateCompletion
{
    BOOL isPrepare = NO;
    
    if(messageModel.bodyType == eMessageBodyType_Voice)
    {
        EaseMessageModel *prevAudioModel = self.audioMessageModel;
        EaseMessageModel *currentAudioModel = messageModel;
        self.audioMessageModel = messageModel;
        
        BOOL isPlaying = messageModel.isMediaPlaying;
        if (isPlaying) {
            messageModel.isMediaPlaying = NO;
            self.audioMessageModel = nil;
            currentAudioModel = nil;
            [[EMCDDeviceManager sharedInstance] stopPlaying];
        }
        else {
            messageModel.isMediaPlaying = YES;
            prevAudioModel.isMediaPlaying = NO;
            isPrepare = YES;
            
            if (!messageModel.isMediaPlayed) {
                messageModel.isMediaPlayed = YES;
                EMMessage *chatMessage = messageModel.message;
                if (chatMessage.ext) {
                    NSMutableDictionary *dict = [chatMessage.ext mutableCopy];
                    if (![[dict objectForKey:@"isPlayed"] boolValue]) {
                        [dict setObject:@YES forKey:@"isPlayed"];
                        chatMessage.ext = dict;
                        [chatMessage updateMessageExtToDB];
                    }
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:chatMessage.ext];
                    [dic setObject:@YES forKey:@"isPlayed"];
                    chatMessage.ext = dic;
                    [chatMessage updateMessageExtToDB];
                }
            }
        }
        
        if (updateCompletion) {
            updateCompletion(prevAudioModel, currentAudioModel);
        }
    }
    
    return isPrepare;
}

- (EaseMessageModel *)stopMessageAudioModel
{
    EaseMessageModel *model = nil;
    if (self.audioMessageModel.bodyType == eMessageBodyType_Voice) {
        if (self.audioMessageModel.isMediaPlaying) {
            model = self.audioMessageModel;
        }
        self.audioMessageModel.isMediaPlaying = NO;
        self.audioMessageModel = nil;
    }
    
    return model;
}


@end
