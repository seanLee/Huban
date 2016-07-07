//
//  NewTweetViewController.m
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTopTextView_Height 100.f

#import "NewTweetViewController.h"
#import "UIPlaceHolderTextView.h"
#import "TitleLeftIconCell.h"
#import "TweetImagesPickCell.h"
#import "QBImagePickerController.h"
#import "BaseNavigationController.h"

@interface NewTweetViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate ,UINavigationControllerDelegate, QBImagePickerControllerDelegate>
@property (strong, nonatomic) Tweet *sendedTweet;
@property (strong, nonatomic) UIPlaceHolderTextView *tweetTextView;
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *sendItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendClicked)];
    self.navigationItem.rightBarButtonItem = sendItem;
    
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
    _sendedTweet = [Tweet new];
    RAC(sendItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, sendedTweet.content),
                                                        RACObserve(self, sendedTweet.tweetImages)]
                                               reduce:^id(NSString *stringStr, NSArray *imageArray){
                                                   return @((stringStr && stringStr.length > 0) || (imageArray && imageArray.count > 0));
                                               }];
}

#pragma mark - Action
- (void)sendClicked {
    NSLog(@"发送");
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [_tweetTextView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    _sendedTweet.content = text;
    return YES;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0?1:2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0?[TweetImagesPickCell cellHeightWithObj:_sendedTweet]:[TitleLeftIconCell cellHeight];
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
        cell.curTweet = _sendedTweet;
        cell.addPhotoBlock = ^{
            [weakSelf showActionForPhoto];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    }
    TitleLeftIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleLeftIconCell forIndexPath:indexPath];
    switch (indexPath.row) {
        case 1:
            [cell setTitle:@"所在位置" icon:@"icon_location"];
            break;
        default:
            [cell setTitle:@"谁可以看" icon:@"icon_right"];
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
}

#pragma mark - Private Method
- (void)showActionForPhoto{
    @weakify(self);
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
        }else if (_sendedTweet.tweetImages.count >= 9) {
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
        [imagePickerController.selectedAssetURLs addObjectsFromArray:_sendedTweet.selectedAssetURLs];
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
        [_sendedTweet addASelectedAssetURL:assetURL];
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QBImagePickerControllerDelegate


- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
@end
