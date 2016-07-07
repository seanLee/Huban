//
//  AroundViewController.m
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AroundViewController.h"
#import "AroundUserCell.h"
#import "UserInfoViewController.h"
#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"
#import "NearByPersons.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface AroundViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;

@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (strong, nonatomic) NearByPersons *nearBys;
@end

@implementation AroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"周边的人";
    
    //bar Item
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(moreClicked)]];
    
    //tableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[AroundUserCell class] forCellReuseIdentifier:kCellIdentifier_AroundUserCell];
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
    
    _nearBys = [[NearByPersons alloc] init];
    
    [self refreshFirst];
}

#pragma mark - Refresh
- (void)refreshFirst {
    [self.myTableView reloadData];
    _myTableView.showsInfiniteScrolling = _nearBys.canLoadMore;
    
    if (_nearBys.list.count == 0) {
        [self refresh];
    }
    if (!_nearBys.isLoading) {
        [self.view configBlankPage:EaseBlankPageTypeTweetPrivateOther hasData:(_nearBys.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
            [self sendRequest];
        }];
    }
}

- (void)refresh {
    if (_nearBys.isLoading) {
        return;
    }
    _nearBys.willLoadMore = NO;
    _nearBys.curPage = 0;
    [self sendRequest];
}

- (void)refreshMore {
    if (_nearBys.isLoading || !_nearBys.canLoadMore) {
        return;
    }
    _nearBys.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest {
    if (_nearBys.list.count <= 0) {
        [self.view beginLoading];
    }
    //获取坐标
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        self.nearBys.latitude = [NSNumber numberWithDouble:userLocation.location.coordinate.latitude];
        self.nearBys.longtitude = [NSNumber numberWithDouble:userLocation.location.coordinate.longitude];
        [self requestNearByUsers];
    }];
}

- (void)requestNearByUsers {
    @weakify(self);
    [[NetAPIManager shareManager] request_nearByWithParams:_nearBys andBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        [self.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [self.nearBys configWithNearBys:data];
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = self.nearBys.canLoadMore;
        }
        [self.view configBlankPage:EaseBlankPageTypeTweetPrivateOther hasData:(self.nearBys.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [self sendRequest];
        }];
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearBys.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AroundUserCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AroundUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AroundUserCell forIndexPath:indexPath];
    if (indexPath.row < self.nearBys.list.count) {
        cell.curUser = self.nearBys.list[indexPath.row];
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.infoType = UserInfoTypeAround;
    User *curUser = self.nearBys.list[indexPath.row];
    vc.userCode = curUser.usercode;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (void)moreClicked {
    @weakify(self);
    [[UIActionSheet bk_actionSheetCustomWithTitle:nil buttonTitles:@[@"清除位置信息并退出"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        @strongify(self);
        if (index == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocationAuth];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }] showInView:self.view];
}
@end
