//
//  MyCollectionViewController.m
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "MyCollectionViewController.h"
#import "TweetCell.h"
#import "UserInfoViewController.h"
#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"


@interface MyCollectionViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableIndexSet *showMoreDetailIndexSet;
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (strong, nonatomic) Topics *curTopics;
@end

@implementation MyCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"收藏";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetCell class] forCellReuseIdentifier:kCellIentifier_TweetCell];
        [tableView registerClass:[TweetCell class] forCellReuseIdentifier:kCellIentifier_TweetCell_Media];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    {
        @weakify(self);
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            @strongify(self);
            [self refreshMore];
        }];
    }
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _curTopics = [[Topics alloc] init];
    _curTopics.userCode = _userCode;
    
    _showMoreDetailIndexSet = [[NSMutableIndexSet alloc] init]; //保存用户显示状态
    
    [self refreshFirst];
}

- (void)refreshFirst {
    [self.myTableView reloadData];
    
    _myTableView.showsInfiniteScrolling = _curTopics.canLoadMore;
    
    if (_curTopics.list.count == 0) {
        [self refresh];
    }
}

- (void)refresh {
    if (_curTopics.isLoading) {
        return;
    }
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
    [[NetAPIManager shareManager] request_get_collectionTopicWithParams:_curTopics andBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        [self.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [self.curTopics configWithFavoriteTopics:data];
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = self.curTopics.canLoadMore;
        }
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _curTopics.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTopic *curFavoriteTopic = _curTopics.list[indexPath.section];
    Topic *curTopic = [[Topic alloc] initWithFavoriteTopic:curFavoriteTopic];
    __weak typeof(self) weakSelf = self;
    TweetCell *cell;
    BOOL canShowDetail = [_showMoreDetailIndexSet containsIndex:indexPath.section];
    if ([curTopic isKindOfClass:[Topic class]]) {
        if ([curTopic topicMedium].count == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetCell forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetCell_Media forIndexPath:indexPath];
        }
        if ([curTopic.usercode isEqualToString:[Login curLoginUser].usercode]) {
            cell.actionType = ActionType_Delete;
        } else {
            cell.actionType = ActionType_Shield;
        }
        cell.curTopic = curTopic;
        cell.topicType = TopicTypeCollection;
        [cell resetState:canShowDetail];
        @weakify(self);
        cell.showMoreDetailBlock = ^(BOOL showMoreDetail) {
            @strongify(self);
            if (showMoreDetail) {
                [self.showMoreDetailIndexSet addIndex:indexPath.section];
            } else {
                [self.showMoreDetailIndexSet removeIndex:indexPath.section];
            }
            [weakSelf.myTableView reloadData];
        };
        cell.userInfoBlock = ^(NSString *userCode) {
            UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
            userInfoVC.infoType = UserInfoTypeNormal;
            userInfoVC.userCode = userCode;
            [weakSelf.navigationController pushViewController:userInfoVC animated:YES];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setEditing:NO animated:YES];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FavoriteTopic *curFavoriteTopic = _curTopics.list[indexPath.section];
        [self deleteFavoriteWithTopic:curFavoriteTopic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canShowDetail = [_showMoreDetailIndexSet containsIndex:indexPath.section];
    FavoriteTopic *curFavoriteTopic = _curTopics.list[indexPath.section];
    Topic *curTopic = [[Topic alloc] initWithFavoriteTopic:curFavoriteTopic];
    return  [TweetCell cellHeightWithObj:curTopic andTweetType:TopicTypeCollection canShowFullContent:canShowDetail];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)deleteFavoriteWithTopic:(FavoriteTopic *)topic {
    @weakify(self);
    [[NetAPIManager shareManager] request_delete_favoriteWithParams:topic.topiccode andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            [self.curTopics.list removeObject:topic];
            [self.myTableView reloadData];
        }
    }];
}
@end
