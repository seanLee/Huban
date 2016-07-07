//
//  NewTweetViewController.m
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//



#define kTopTextView_Height 100.f

#import "SendTweetViewController.h"
#import "UIPlaceHolderTextView.h"
#import "TitleLeftIconCell.h"
#import "TweetImagesPickCell.h"
#import "QBImagePickerController.h"
#import "BaseNavigationController.h"
#import "TweetLocationViewController.h"
#import "TweetPrivacyViewController.h"
#import "PhotoBrowserViewController.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface SendTweetViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate ,UINavigationControllerDelegate, QBImagePickerControllerDelegate, MBProgressHUDDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIBarButtonItem *sendItem;
@property (strong, nonatomic) UIPlaceHolderTextView *tweetTextView;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (assign, nonatomic) BOOL didChangePrivaryType;
@end

@implementation SendTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _sendItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendClicked)];
    self.navigationItem.rightBarButtonItem = _sendItem;
    
    //input textView
    //textView
    _tweetTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
    //set Placer
    _tweetTextView.placeholder = @"说点什么吧.....";
    _tweetTextView.returnKeyType = UIReturnKeyDone;
    _tweetTextView.backgroundColor = [UIColor whiteColor];
    _tweetTextView.delegate = self;
    _tweetTextView.layer.borderColor = [UIColor colorWithHexString:@"0xc8c7cc"].CGColor;
    _tweetTextView.layer.borderWidth = .5f;
    _tweetTextView.font = [UIFont systemFontOfSize:14.f];
    _tweetTextView.textColor = SYSFONTCOLOR_BLACK;
    [self.view addSubview:_tweetTextView];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.scrollEnabled = NO;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleLeftIconCell class] forCellReuseIdentifier:kCellIdentifier_TitleLeftIconCell];
        [tableView registerClass:[TweetImagesPickCell class] forCellReuseIdentifier:kCellIdentifier_TweetImagesPickCell];
        [self.view addSubview:tableView];
        tableView;
    });
    
    [_tweetTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kTopTextView_Height);
    }];
    
    [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_tweetTextView.mas_bottom);
        make.right.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    //observe
    RAC(self.sendItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, sendedTopic.topiccontent),
                                                        RACObserve(self, sendedTopic.topicImageArray)]
                                               reduce:^id(NSString *stringStr, NSArray *imageArray){
                                                   return @((stringStr && stringStr.length > 0) || (imageArray && imageArray.count > 0));
                                               }];
    
    if (self == [self.navigationController.viewControllers firstObject]) {
        UIBarButtonItem *cancelButton = [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelClicked)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

#pragma - Set
- (void)setTopicType:(SendTopicType)topicType {
    _topicType = topicType;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (self.topicType) {
        case SendTopicType_ToCityCircle:
            self.sendedTopic.visibletype = [defaults objectForKey:kTweetType_CityCircle]?:@0;
            break;
        case SendTopicType_ToFriendCircle: {
            self.sendedTopic.visibletype = [defaults objectForKey:kTweetType_FriendCircle]?:@0;
            Region *selectedRegion = [[DataBaseManager shareInstance] regionForCityCode:[[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectedCityCode]];
            if (selectedRegion) {
                self.sendedTopic.provcode = selectedRegion.provcode;
                self.sendedTopic.citycode = selectedRegion.citycode;
            } else {
                @weakify(self);
                [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
                    [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:userLocation.location.coordinate.longitude andLatitude:userLocation.location.coordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
                        @strongify(self);
                        [self getLocationStr:location];
                    }];
                }];
            }
        }
            break;
        case SendTopicType_ToAlbum:
            self.sendedTopic.visibletype = [defaults objectForKey:kTweetType_Album]?:@0;
            break;
        default:
            break;
    }
}
- (void)getLocationStr:(BMKReverseGeoCodeResult *)placeMarks {
    NSString *cityName = placeMarks.addressDetail.city; //获取到坐标的城市名称
    Region *currentRegion = [[DataBaseManager shareInstance] regionForFullName:cityName];
    self.sendedTopic.provcode = currentRegion.provcode;
    self.sendedTopic.citycode = currentRegion.citycode;
}

#pragma mark - Get
- (Topic *)sendedTopic {
    if (!_sendedTopic) {
        _sendedTopic = [[Topic alloc] init];
    }
    return _sendedTopic;
}

- (void)setCurRegion:(Region *)curRegion {
    _curRegion = curRegion;
    if (_curRegion) {
        self.sendedTopic.citycode = _curRegion.citycode;
        self.sendedTopic.provcode = _curRegion.provcode;
    }
}

#pragma mark - Action
- (void)sendClicked {
    [_tweetTextView resignFirstResponder];
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.labelText = @"正在发送中.......";
        _hud.delegate = self;
        [_hud show:YES];
        [self.view addSubview:_hud];
    }
    self.sendItem.enabled = NO;
    @weakify(self);
    if (_sendedTopic.topicImageArray.count > 0) { //如果选择了图片,首先上传图片
        [[NetAPIManager shareManager] uploadImagesWithParams:_sendedTopic andBlock:^(id data, NSError *error) {
            @strongify(self);
            self.sendItem.enabled = YES;
            if (data) {
                [self sendTopicWithImagePaths:data];
            }
        }];
    } else {
        [self sendTopicWithImagePaths:nil];
    }
}

- (void)cancelClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Topic
- (void)sendTopicWithImagePaths:(NSString *)imageArrays {
    if (imageArrays) {
        _sendedTopic.topicimages = imageArrays;
    }
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.labelText = @"正在发送中.......";
        _hud.delegate = self;
        [_hud show:YES];
        [self.view addSubview:_hud];
    }
    self.sendItem.enabled = NO;
    @weakify(self);
    [[NetAPIManager shareManager] request_sendTopicWithParams:self.sendedTopic andBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.hud hide:YES];
        self.sendItem.enabled = YES;
        if (data){
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            if (self.fromAlbum) { //如果是从相册进入的
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
            [self showHudTipStr:@"发送成功"];
        }
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [_tweetTextView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    _sendedTopic.topiccontent = textView.text;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0?1:2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0?[TweetImagesPickCell cellHeightWithObj:_sendedTopic]:[TitleLeftIconCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return section == 0?[tableView getHeaderViewWithStr:@"照片" andHeight:24.f andBlock:nil]:
                        [tableView getHeaderViewWithStr:@"" andHeight:24.f andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        TweetImagesPickCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetImagesPickCell forIndexPath:indexPath];
        cell.curTopic = _sendedTopic;
        cell.addPhotoBlock = ^{
            [weakSelf showActionForPhoto];
        };
        cell.photoSelectedBlock = ^(NSInteger selectedIndex,NSMutableDictionary *imageViews) {
            [weakSelf showPhotoBrowserWithIndex:selectedIndex imageViews:imageViews];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }
    TitleLeftIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleLeftIconCell forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            [cell setTitle:@"所在位置" icon:@"icon_location"];
            break;
        default:
            [cell setTitle:@"谁可以看" icon:@"icon_right"];
            [cell setDetailStr:[self privateStr]];
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    cell.showIndicator = YES;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_tweetTextView resignFirstResponder];
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                TweetLocationViewController *vc = [[TweetLocationViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default: {
                @weakify(self);
                TweetPrivacyViewController *vc = [[TweetPrivacyViewController alloc] init];
                vc.privacyType = self.sendedTopic.visibletype.integerValue;
                vc.topicType = self.topicType;
                vc.didSelectedPrivacyType = ^(TweetPrivacyTyep type) {
                    @strongify(self);
                    self.sendedTopic.visibletype = @(type);
                    [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
        }
    }
}

#pragma mark - Private Method
- (NSString *)privateStr {
    NSString *privacyStr;
    switch (self.sendedTopic.visibletype.integerValue) {
        case 0:
            privacyStr = @"公开";
            break;
        case 1:
            privacyStr = @"好友可见";
            break;
        case 2:
            privacyStr = @"陌生人可见";
            break;
        case 3:
            privacyStr = @"秘密";
            break;
        default:
            break;
    }
    return privacyStr;
}

- (void)showPhotoBrowserWithIndex:(NSInteger)curIndex imageViews:(NSMutableDictionary *)imageViews {
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:_sendedTopic.topicImageArray.count];
    for (int i = 0; i < _sendedTopic.topicImageArray.count; i++) {
        TopicImage *imageItem = [_sendedTopic.topicImageArray objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.srcImageView = [imageViews objectForKey:imageViews.allKeys[curIndex]]; // 来源于哪个UIImageView
        photo.image = imageItem.image; // 图片路径
        photo.assetsUrl = imageItem.assetURL;
        [photos addObject:photo];
    }
    PhotoBrowserViewController *vc = [[PhotoBrowserViewController alloc] init];
    vc.photos = photos;
    vc.currentIndex = curIndex;
    @weakify(self);
    vc.deleteImageBlock = ^ (NSMutableArray *assetsUrl) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.sendedTopic.selectedAssetURLs = assetsUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            });
        });
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showActionForPhoto{
    @weakify(self);
    [_tweetTextView resignFirstResponder]; //取消聚焦
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"拍照", @"从相册选择"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        @strongify(self);
        [self photoActionSheet:sheet DismissWithButtonIndex:index];
    }] showInView:self.view];
}

- (void)photoActionSheet:(UIActionSheet *)sheet DismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        拍照
        if (![Helper checkCameraAuthorizationStatus]) {
            return;
        }else if (_sendedTopic.topicImageArray.count >= 9) {
            kTipAlert(@"最多只可选择9张照片，已经选满了。先去掉一张照片再拍照呗～");
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];//进入照相界面
    }else if (buttonIndex == 1){
        //        相册
        if (![Helper checkPhotoLibraryAuthorizationStatus]) {
            return;
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        [imagePickerController.selectedAssetURLs removeAllObjects];
        [imagePickerController.selectedAssetURLs addObjectsFromArray:_sendedTopic.selectedAssetURLs];
        imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 9;
        UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickerImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeImageToSavedPhotosAlbum:[pickerImage CGImage] orientation:(ALAssetOrientation)pickerImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        [_sendedTopic addASelectedAssetURL:assetURL];
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets {
    NSMutableArray *selectedAssetURLs = [NSMutableArray new];
    [imagePickerController.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [selectedAssetURLs addObject:obj];
    }];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.sendedTopic.selectedAssetURLs = selectedAssetURLs;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    hud = nil;
}
@end
