//
//  AlbumViewController.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumListCell.h"
#import "QBImagePickerController.h"
#import "BaseNavigationController.h"
#import "SendTweetViewController.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "TweetDetailViewController.h"

@interface AlbumViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBImagePickerControllerDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIBarButtonItem *sendTweetItem;
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *dataItems;
@property (strong, nonatomic) NSMutableDictionary *topicDict;

@property (strong, nonatomic) Topics *curTopics;
@property (strong, nonatomic) Topic *sendTopic;
@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _sendTweetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_newTweet"] style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[AlbumListCell class] forCellReuseIdentifier:kCellIdentifier_AlbumListCell_Index];
        [tableView registerClass:[AlbumListCell class] forCellReuseIdentifier:kCellIdentifier_AlbumListCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        {
            @weakify(self);
            [tableView addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                [self refreshMore];
            }];
        }
        tableView;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _sendTopic = [[Topic alloc] init];
    _curTopics = [[Topics alloc] init];
    _curTopics.userCode = self.relation.contactcode;
    
    _dataItems = [NSMutableArray new];
    _topicDict = [NSMutableDictionary new];
    //new object
    [self refreshFirst];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [self isSender]?@"我的相册":[self.relation.contactmemo isEmpty]?self.relation.contactname:self.relation.contactmemo;
    self.navigationItem.rightBarButtonItem = [self isSender]?self.sendTweetItem:nil;
}

- (void)refreshFirst {
    [self.myTableView reloadData];
    
    _myTableView.showsInfiniteScrolling = _curTopics.canLoadMore;
    
    if (_curTopics.list.count == 0) {
        [self refresh];
    }
    if (!_curTopics.isLoading) {
        [self.view configBlankPage:[self isSender]?EaseBlankPageTypeTweetPrivate:EaseBlankPageTypeTweetPrivateOther hasData:(_curTopics.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
            [self sendRequest];
        }];
    }
}

- (BOOL)isSender {
    return [self.relation.contactcode isEqualToString:[Login curLoginUser].usercode];
}

- (void)refresh {
    if (_curTopics.isLoading) {
        return;
    }
    [_dataItems removeAllObjects];
    [_topicDict removeAllObjects];
    _curTopics.willLoadMore = NO;
    _curTopics.curPage = 0;
    [self sendRequest];
}

- (void)refreshMore {
    if (_curTopics.isLoading || !_curTopics.canLoadMore) {
        return;
    }
    _curTopics.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest {
    if (_curTopics.list.count <= 0) {
        [self.view beginLoading];
    }
    @weakify(self);
    [[NetAPIManager shareManager] request_get_albumTopicWithParams:_curTopics andBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        [self.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [self.curTopics configWithTopics:data];
            NSArray *dataArr = [NSObject arrayFromJSON:data[@"list"] ofObjects:@"Topic"];
            [self configDataWithArray:dataArr];
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = self.curTopics.canLoadMore;
        }
        if (![self isSender]) { //如果不是自己的相册
            [self.view configBlankPage:EaseBlankPageTypeTweetPrivateOther hasData:(_curTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [self sendRequest];
            }];
        }
    }];
}

- (void)configDataWithArray:(NSArray *)array {
    //get the dateKey
    for (Topic *topic in self.curTopics.list) {
        NSString *dateStr = [topic.createdate string_yyyy_MM_dd];
        if (![self.dataItems containsObject:dateStr]) {
            [self.dataItems addObject:dateStr];
        }
        //reload the date
        NSMutableArray *tempArr = [[self topicsForDate:dateStr] mutableCopy];
        if (!tempArr) {
            tempArr = [[NSMutableArray alloc] init];
        }
        [tempArr addObject:topic];
        [self.topicDict setObject:[tempArr copy] forKey:dateStr];
    }
}

- (NSArray *)topicsForDate:(NSString *)dateKey {
    return [self.topicDict objectForKey:dateKey];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isSender]) {
        return MAX(_dataItems.count, 1);
    }
    return _dataItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataItems.count == 0) {
        return [AlbumListCell cellHeightWidhObj:nil isIndex:YES];
    }
    NSString *dateStr = _dataItems[indexPath.section];
    return [AlbumListCell cellHeightWidhObj:[self topicsForDate:dateStr] isIndex:(indexPath.section == 0 && [self isSender])];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    AlbumListCell *cell;
    
    if (_dataItems.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AlbumListCell_Index forIndexPath:indexPath];
        cell.topics = nil;
        cell.addPhotoBlock = ^{
            @strongify(self);
            [self showActionForPhoto];
        };
        return cell;
    }
    
    if (indexPath.section == 0 && [self isSender]) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AlbumListCell_Index forIndexPath:indexPath];
        cell.addPhotoBlock = ^{
            @strongify(self);
            [self showActionForPhoto];
        };
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AlbumListCell forIndexPath:indexPath];
    }
    cell.itemSelectedBlock = ^(Topic *curTopic) {
        @strongify(self);
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        vc.curTopic = curTopic;
        [self.navigationController pushViewController:vc animated:YES];
    };
    NSString *dateStr = _dataItems[indexPath.section];
    NSArray *topics = [self topicsForDate:dateStr];
    cell.topics = topics;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:20.f color:[UIColor clearColor] andBlock:nil];
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
        }else if (_sendTopic.topicImageArray.count >= 9) {
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
        [imagePickerController.selectedAssetURLs addObjectsFromArray:_sendTopic.selectedAssetURLs];
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
    @weakify(self);
    [assetsLibrary writeImageToSavedPhotosAlbum:[pickerImage CGImage] orientation:(ALAssetOrientation)pickerImage.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        @strongify(self);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sendTopic addASelectedAssetURL:assetURL];
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                SendTweetViewController *vc = [[SendTweetViewController alloc] init];
                vc.refreshBlock = ^ {
                    [self refresh];
                };
                vc.sendedTopic = self.sendTopic;
                vc.topicType = SendTopicType_ToAlbum;
                vc.fromAlbum = YES;
                UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:vc];
                [self presentViewController:navigationController animated:YES completion:NULL];
            });
        });
    }];
    [picker dismissViewControllerAnimated:YES completion:^{}];
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
        self.sendTopic.selectedAssetURLs = selectedAssetURLs;
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            SendTweetViewController *vc = [[SendTweetViewController alloc] init];
            vc.refreshBlock = ^ {
                [self refresh];
            };
            vc.sendedTopic = self.sendTopic;
            vc.topicType = SendTopicType_ToAlbum;
            vc.fromAlbum = YES;
            UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navigationController animated:YES completion:NULL];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action
- (void)sendAction {
    SendTweetViewController *vc = [[SendTweetViewController alloc] init];
    @weakify(self);
    vc.refreshBlock = ^ {
        @strongify(self);
        self.sendTopic.topiccontent = @"";
        [self refresh];
    };
    vc.sendedTopic = self.sendTopic;
    vc.topicType = SendTopicType_ToAlbum;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
