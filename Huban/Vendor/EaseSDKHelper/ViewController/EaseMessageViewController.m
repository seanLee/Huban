//
//  EaseMessageViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseMessageViewController.h"

#import "NSDate+EaseMob.h"
#import "EaseMessageReadManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UserInfoViewController.h"
#import "QBImagePickerController.h"
#import "BaseNavigationController.h"
#import "LocationDetailViewController.h"
#import "SendLocationViewController.h"
#import "TranspondViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

#define KHintAdjustY    50

@interface EaseMessageViewController ()
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    
    dispatch_queue_t _messageQueue;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;

@end

@implementation EaseMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:conversationChatter conversationType:conversationType];
        
        _messageCountOfPage = 10;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        
        [_conversation markAllMessagesAsRead:YES];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
      
    
    //初始化手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    //键盘
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeChat];
    _myMsgInputView.delegate = self;
    _myMsgInputView.isAlwaysShow = YES;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(_myMsgInputView.frame), 0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    //注册代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [self registerEaseMobLiteNotification];
    
    
    if (self.conversation.conversationType == eConversationTypeChatRoom)
    {
        [self joinChatroom:self.conversation.chatter];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [self unregisterEaseMobLiteNotification];
    
    if (_conversation.conversationType == eConversationTypeChatRoom && !_isKicked)
    {
        //退出聊天室，删除会话
        NSString *chatter = [_conversation.chatter copy];
        [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter completion:^(EMChatroom *chatroom, EMError *error){
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
        }];
    }
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
    
    if (self.scrollToBottomWhenAppear) {
        [self _scrollViewToBottom:NO];
    }

    self.scrollToBottomWhenAppear = YES;
    
    if (_myMsgInputView) {
        [_myMsgInputView prepareToShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
    
    self.isViewDidAppear = NO;
    [_conversation markAllMessagesAsRead:YES];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - chatroom

- (void)saveChatroom:(EMChatroom *)chatroom
{
    NSString *chatroomName = chatroom.chatroomSubject ? chatroom.chatroomSubject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId])
    {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

- (void)joinChatroom:(NSString *)chatroomId
{
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.joining",@"Joining the chatroom")];
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinChatroom:chatroomId completion:^(EMChatroom *chatroom, EMError *error){
        if (weakSelf)
        {
            EaseMessageViewController *strongSelf = weakSelf;
            [strongSelf hideHud];
            if (error && (error.errorCode != EMErrorChatroomJoined))
            {
                [strongSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"chatroom.joinFailed",@"join chatroom \'%@\' failed"), chatroomId]];
            }
            else
            {
                [strongSelf saveChatroom:chatroom];
            }
        }
        else
        {
            if (!error || (error.errorCode == EMErrorChatroomJoined))
            {
                [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatroomId completion:^(EMChatroom *chatroom, EMError *error){
                    [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatroomId deleteMessages:YES append2Chat:YES];
                }];
            }
        }
    }];
}

#pragma mark - setter

- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self _shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - private helper

- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (BOOL)_canRecord
{
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

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(MessageBodyType)messageType
{
//    if (_menuController == nil) {
//        _menuController = [UIMenuController sharedMenuController];
//    }
//    
//    if (_deleteMenuItem == nil) {
//        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
//    }
//    
//    if (_copyMenuItem == nil) {
//        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
//    }
//    
//    if (messageType == eMessageBodyType_Text) {
//        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
//    } else {
//        [_menuController setMenuItems:@[_deleteMenuItem]];
//    }
//    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
//    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (EMMessageType)_messageTypeFromConversationType
{
    EMMessageType type = eMessageTypeChat;
    switch (self.conversation.conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (BOOL)_shouldSendHasReadAckForMessage:(EMMessage *)message
                                   read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:NO];
        }
        else{
            isSend = [self _shouldSendHasReadAckForMessage:message
                                                      read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        dispatch_async(_messageQueue, ^{
            for (EMMessage *message in unreadMessages)
            {
                [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
            }
        });
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    LocationDetailViewController *vc = [[LocationDetailViewController alloc] init];
    vc.message = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)[model.message.messageBodies firstObject];
    
    //判断本地路劲是否存在
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        return;
    }
    
    dispatch_block_t block = ^{
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        block();
        return;
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    __weak EaseMessageViewController *weakSelf = self;
    id<IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            block();
        }else{
            [weakSelf showHint:NSLocalizedString(@"message.videoFail", @"video for failure!")];
        }
    } onQueue:nil];
}

- (void)_imageMessageCellSelected:(id<IMessageModel>)model
{
    __weak EaseMessageViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message.messageBodies firstObject];
    
    if ([imageBody messageBodyType] == eMessageBodyType_Image) {
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed)
        {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                //发送已读回执
                [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                NSString *localPath = model.message == nil ? model.fileLocalPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    if (image)
                    {
                        @weakify(self);
                        [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image]withTranspondBlock:^ (UIImage *transpondImage){
                            @strongify(self);
                           [self transpondMessageWithImage:transpondImage];
                        }];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return;
                }
            }
            [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"message.downloadingImage", @"downloading a image...")];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    //发送已读回执
                    [weakSelf _sendHasReadResponseForMessages:@[model.message] isRead:YES];
                    NSString *localPath = aMessage == nil ? model.fileLocalPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        //                                weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            @weakify(self);
                            [[EaseMessageReadManager defaultManager] showBrowserWithImages:@[image] withTranspondBlock:^ (UIImage *transpondImage){
                                @strongify(self);
                                [self transpondMessageWithImage:transpondImage];
                            }];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHint:NSLocalizedString(@"message.imageFail", @"image for failure!")];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:NSLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
                }
                
            } onQueue:nil];
        }
    }
}

- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        return;
    }
    
    // 播放音频
    if (model.bodyType == eMessageBodyType_Voice) {
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak EaseMessageViewController *weakSelf = self;
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak EaseMessageViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - pivate data

- (void)_loadMessagesBefore:(long long)timestamp
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *moreMessages = nil;
        if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(messageViewController:loadMessageFromTimestamp:count:)]) {
            moreMessages = [weakSelf.dataSource messageViewController:weakSelf loadMessageFromTimestamp:timestamp count:count];
        }
        else{
            moreMessages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];;
        }
        
        if ([moreMessages count] == 0) {
            return;
        }
        
        //格式化消息
        NSArray *formattedMessages = [weakSelf formatMessages:moreMessages];
        
        NSInteger scrollToIndex = 0;
        if (isAppend) {
            [weakSelf.messsagesSource insertObjects:moreMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [moreMessages count])]];
            
            //合并消息
            id object = [weakSelf.dataArray firstObject];
            if ([object isKindOfClass:[NSString class]])
            {
                NSString *timestamp = object;
                [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                    if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                    {
                        [weakSelf.dataArray removeObjectAtIndex:0];
                        *stop = YES;
                    }
                }];
            }
            scrollToIndex = [weakSelf.dataArray count];
            [weakSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
        }
        else{
            [weakSelf.messsagesSource removeAllObjects];
            [weakSelf.messsagesSource addObjectsFromArray:moreMessages];
            
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:formattedMessages];
        }
        
        EMMessage *latest = [weakSelf.messsagesSource lastObject];
        weakSelf.messageTimeIntervalTag = latest.timestamp;
        
        //刷新页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.dataArray count] - scrollToIndex - 1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
        
        //从数据库导入时重新下载没有下载成功的附件
        for (EMMessage *message in moreMessages)
        {
            [weakSelf _downloadMessageAttachments:message];
        }
        
        //发送已读回执
        [weakSelf _sendHasReadResponseForMessages:moreMessages
                                       isRead:NO];
    });
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.myMsgInputView isAndResignFirstResponder];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
//    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
//    {
//        CGPoint location = [recognizer locationInView:self.tableView];
//        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
//        BOOL canLongPress = NO;
//        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
//            canLongPress = [_dataSource messageViewController:self
//                                   canLongPressRowAtIndexPath:indexPath];
//        }
//        
//        if (!canLongPress) {
//            return;
//        }
//        
//        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
//            [_dataSource messageViewController:self
//                    didLongPressRowAtIndexPath:indexPath];
//        }
//        else{
//            id object = [self.dataArray objectAtIndex:indexPath.row];
//            if (![object isKindOfClass:[NSString class]]) {
//                EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//                [cell becomeFirstResponder];
//                _menuIndexPath = indexPath;
//                [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
//            }
//        }
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.section];
    
    //时间cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    else{
        id<IMessageModel> model = object;
        
        NSString *reuseIdentifer = [ChatViewCell cellIdentifierForMessage:model.bodyType];
        
        //set the cell
        ChatViewCell *cell ;
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifer];
        
        // Configure the cell...
        if (cell == nil) {
            cell = [[ChatViewCell alloc] initWithReuseIdentifier:reuseIdentifer andMessage:model];
        }
        @weakify(self)
        cell.userHeaderTapBlock = ^(User *curUser) {
            @strongify(self);
            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
            vc.fromChatVC = YES;
            vc.popToChatVCBlock = ^ {
                [self.navigationController popToViewController:self animated:YES];
            };
            vc.userCode = curUser.usercode;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.didTapCellBlock = ^ {
            @strongify(self);
            [self messageCellSelected:model];
        };
        cell.copyTextBlock = ^{
            @strongify(self);
            self.menuIndexPath = indexPath;
            [self copyText:model];
        };
        cell.deleteBlock = ^ {
            @strongify(self);
            self.menuIndexPath = indexPath;
            [self deleteMenuClick];
        };
        cell.transpondBlock = ^ (UIImage *transpondImage){
            @strongify(self);
            TranspondViewController *vc = [[TranspondViewController alloc] init];
            vc.selectedItemsBlock = ^(NSArray *selectedItems) {
                for (Contact *contact in selectedItems) {
                    [self transpondImageMessage:transpondImage andToUser:contact.contactcode];
                }
            };
            BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:baseNav animated:YES completion:nil];
        };
        cell.curMessage = model;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id object = [self.dataArray objectAtIndex:section];
    if ([object isKindOfClass:[NSString class]]) {
        return 0;
    }
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     return [tableView getHeaderViewWithStr:nil andHeight:10.f color:[UIColor clearColor] andBlock:nil];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.section];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }
    else{
        id<IMessageModel> model = object;
        return [ChatViewCell cellHeightWithObj:model];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [self sendImageMessage:orgImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

#pragma mark - EaseMessageCellDelegate
- (void)messageCellSelected:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:)]) {
        BOOL flag = [_delegate messageViewController:self didSelectMessageModel:model];
        if (flag) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
            return;
        }
    }
    
    switch (model.bodyType) {
        case eMessageBodyType_Image:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:model];
        }
            break;
        case eMessageBodyType_Location:
        {
             [self _locationMessageCellSelected:model];
        }
            break;
        case eMessageBodyType_Voice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
        case eMessageBodyType_Video:
        {
            [self _videoMessageCellSelected:model];

        }
            break;
        case eMessageBodyType_File:
        {
            _scrollToBottomWhenAppear = NO;
            [self showHint:@"Custom implementation!"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - EMChatToolbarDelegate
- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}


#pragma mark - EMChatManagerChatDelegate

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count])
    {
        return;
    }
    
    if ([self _shouldMarkMessageAsRead])
    {
        [self.conversation markAllMessagesAsRead:YES];
    }
    
    long long timestamp = 0;
    if(self.conversation.latestMessage){
        timestamp = self.conversation.latestMessage.timestamp + 1;
    }
    else{
        timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    }
    [self _loadMessagesBefore:timestamp
                        count:[self.messsagesSource count] + [offlineMessages count]
                       append:NO];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (_conversation.conversationType != eConversationTypeChat && [group.groupId isEqualToString:_conversation.chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessageToDataSource:message progress:nil];
        
        [self _sendHasReadResponseForMessages:@[message]
                                       isRead:NO];
        
        if ([self _shouldMarkMessageAsRead])
        {
            [self.conversation markMessageWithId:message.messageId asRead:YES];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
        [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
    }
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [self.conversation.chatter isEqualToString:conversationChatter])
    {
        __weak typeof(self) weakSelf = self;
        id<IMessageModel> model = nil;
        for (int i = 0; i < self.dataArray.count; i ++) {
            id object = [self.dataArray objectAtIndex:i];
            if ([object conformsToProtocol:@protocol(IMessageModel)]) {
                model = (id<IMessageModel>)object;
                if ([messageId isEqualToString:model.message.messageId]) {
                    model.message.deliveryState = eMessageDeliveryState_Failure;
                    
                    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didFailSendingMessageModel:error:)]) {
                        [_delegate messageViewController:self didFailSendingMessageModel:model error:error];
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:i]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        if (error && error.errorCode == EMErrorMessageContainSensitiveWords)
                        {
                            
                        }
                    }
                    break;
                }
            }
        }
    }
}

- (void)didReceiveHasReadResponse:(EMReceipt *)receipt
{
    if (![self.conversation.chatter isEqualToString:receipt.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
        [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
    }
    else{
        [self.tableView reloadData];
    }
}

- (void)didSendMessage:(EMMessage *)message
                 error:(EMError *)error
{
    if (![self.conversation.chatter isEqualToString:message.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (error) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didFailSendingMessageModel:error:)]) {
            [_delegate messageViewController:self didFailSendingMessageModel:model error:error];
        }
        else{
            [self.tableView reloadData];
        }
    }
    else{
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSendMessageModel:)]) {
            [_delegate messageViewController:self didSendMessageModel:model];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataArray.count; i ++) {
                id object = [weakSelf.dataArray objectAtIndex:i];
                if ([object isKindOfClass:[EaseMessageModel class]]) {
                    id<IMessageModel> model = object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        id<IMessageModel> model = nil;
                        if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                            model = [weakSelf.dataSource messageViewController:self modelForMessage:message];
                        }
                        else{
                            model = [[EaseMessageModel alloc] initWithMessage:message];
                            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
                            model.failImageName = @"imageDownloadFail";
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataArray replaceObjectAtIndex:i withObject:model];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:i]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - IEMChatProgressDelegate
- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody
{
    if (![self.conversation.chatter isEqualToString:message.conversationChatter]){
        return;
    }
    
    __block id<IMessageModel> model = nil;
    __block BOOL isHave = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj conformsToProtocol:@protocol(IMessageModel)])
         {
             model = (id<IMessageModel>)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.progress = progress;
                 isHave = YES;
                 *stop = YES;
             }
         }
     }];
    
    if(!isHave){
        return;
    }
    
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
        [_dataSource messageViewController:self
                            updateProgress:progress
                              messageModel:model
                               messageBody:messageBody];
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action
- (void)copyText:(id<IMessageModel>)model
{
    if (model) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.text;
    }
    self.menuIndexPath = nil;
}

- (void)deleteMenuClick
{
    if (self.menuIndexPath && self.menuIndexPath.section > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.section];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.section];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation removeMessage:model.message];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.section - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.section - 1)];
            if (self.menuIndexPath.section + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.section + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.section - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:(self.menuIndexPath.section - 1)]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteSections:indexs withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
    
    self.menuIndexPath = nil;
}

- (void)transpondMessageWithImage:(UIImage *)transpondImage
{
    TranspondViewController *vc = [[TranspondViewController alloc] init];
    @weakify(self);
    vc.selectedItemsBlock = ^(NSArray *selectedItems) {
        @strongify(self);
        for (Contact *contact in selectedItems) {
            [self transpondImageMessage:transpondImage andToUser:contact.contactcode];
        }
    };
    BaseNavigationController *baseNav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:baseNav animated:YES completion:nil];
}

#pragma mark - public 

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    for (EMMessage *message in messages) {
        //计算時間间隔
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:stringForDate:)]) {
                timeStr = [_dataSource messageViewController:self stringForDate:messageDate];
            }
            else{
                timeStr = [messageDate formattedTime];
            }
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //构建数据模型
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:message];
            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
            model.failImageName = @"imageDownloadFail";
        }

        if (model) {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id<IEMChatProgressDelegate>)progress
{
    [self.messsagesSource addObject:message];
    
     __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[weakSelf.dataArray count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - public

- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    long long timestamp = 0;
    if ([self.messsagesSource count] > 0) {
        timestamp = [(EMMessage *)self.messsagesSource.firstObject timestamp];
    }
    else if(self.conversation.latestMessage){
        timestamp = self.conversation.latestMessage.timestamp + 1;
    }
    else{
        timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    }
    [self _loadMessagesBefore:timestamp count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - send message

- (void)sendTextMessage:(NSString *)text
{
    [self sendTextMessage:text withExt:nil];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
    EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                   to:self.conversation.chatter
                                          messageType:[self _messageTypeFromConversationType]
                                    requireEncryption:NO
                                           messageExt:ext];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:self.conversation.chatter
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil];
    [self addMessageToDataSource:message
                        progress:nil];
}

- (void)sendImageMessage:(UIImage *)image
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Image];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                             to:self.conversation.chatter
                                                    messageType:[self _messageTypeFromConversationType]
                                              requireEncryption:NO
                                                     messageExt:nil
                                                       progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)transpondImageMessage:(UIImage *)transpondImage andToUser:(NSString *)toUser {
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Image];
    }
    else{
        progress = self;
    }
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:transpondImage
                                                               to:toUser
                                                      messageType:[self _messageTypeFromConversationType]
                                                requireEncryption:NO
                                                       messageExt:nil
                                                         progress:progress];
    if ([toUser isEqualToString:self.conversation.chatter]) {
        [self addMessageToDataSource:message
                            progress:progress];
    }
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Voice];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                           duration:duration
                                                                 to:self.conversation.chatter
                                                        messageType:[self _messageTypeFromConversationType]
                                                  requireEncryption:NO
                                                         messageExt:nil
                                                           progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id<IEMChatProgressDelegate> progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:eMessageBodyType_Video];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                           to:self.conversation.chatter
                                                  messageType:[self _messageTypeFromConversationType]
                                            requireEncryption:NO
                                                   messageExt:nil
                                                     progress:progress];
    [self addMessageToDataSource:message
                        progress:progress];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
    [self.tableView reloadData];
    
    //回到前台时
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self _shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

#pragma mark - EaseMobDelegate
- (void)registerEaseMobLiteNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterEaseMobLiteNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectImages:(NSArray *)images {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        for (UIImage *subImage in images) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendImageMessage:subImage];
            });
        }
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom{
    UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    //调整内容
    static BOOL keyboard_is_down = YES;
    static CGPoint keyboard_down_ContentOffset;
    static CGFloat keyboard_down_InputViewHeight;
    if (heightToBottom > CGRectGetHeight(inputView.frame)) {
        if (keyboard_is_down) {
            keyboard_down_ContentOffset = self.tableView.contentOffset;
            keyboard_down_InputViewHeight = CGRectGetHeight(inputView.frame);
        }
        keyboard_is_down = NO;
        
        CGPoint contentOffset = keyboard_down_ContentOffset;
        CGFloat spaceHeight = MAX(0, CGRectGetHeight(self.tableView.frame) - self.tableView.contentSize.height - keyboard_down_InputViewHeight);
        contentOffset.y += MAX(0, heightToBottom - keyboard_down_InputViewHeight - spaceHeight);
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }else{
        keyboard_is_down = YES;
    }
}

- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text{
    [self sendTextMessage:text];
}

- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration {
    [self sendVoiceMessageWithLocalPath:file duration:duration];
}

- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index{
    if (index == 0) { //发送图片
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 9;
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    } else if (index == 1) { //发送地理位置
        SendLocationViewController *vc = [[SendLocationViewController alloc] init];
        @weakify(self);
        vc.didClickedSendButtonBlock = ^ (double longtitude,double latitude,NSString *address){
            @strongify(self);
            [self sendLocationMessageLatitude:latitude longitude:longtitude andAddress:address];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.tableView) {
        [_myMsgInputView isAndResignFirstResponder];
    }
}
@end
