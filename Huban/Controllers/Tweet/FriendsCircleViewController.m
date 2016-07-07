//
//  FriendsCircleViewController.m
//  Huban
//
//  Created by sean on 15/8/18.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "TweetCell.h"
#import "TweetDetailViewController.h"
#import "UserInfoViewController.h"
#import "SendTweetViewController.h"
#import "SVPullToRefresh.h"
#import "ODRefreshControl.h"

@interface FriendsCircleViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableIndexSet *showMoreDetailIndexSet;

@property (strong, nonatomic) Topics *curTopics;
@end

@implementation FriendsCircleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友生活";
    
    UIBarButtonItem *newTweetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_newTweet"] style:UIBarButtonItemStylePlain target:self action:@selector(newTweetClicked:)];
    self.navigationItem.rightBarButtonItem = newTweetItem;
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        [tableview registerClass:[TweetCell class] forCellReuseIdentifier:kCellIentifier_TweetCell];
        [tableview registerClass:[TweetCell class] forCellReuseIdentifier:kCellIentifier_TweetCell_Media];
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableview];
        [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        {
            @weakify(self);
            [tableview addInfiniteScrollingWithActionHandler:^{
                @strongify(self);
                [self refreshMore];
            }];
        }
        tableview;
    });
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _curTopics = [[Topics alloc] init];
    
    _showMoreDetailIndexSet = [[NSMutableIndexSet alloc] init]; //保存用户显示状态
    
    [self refreshFirst];
}

#pragma mark - Refresh
- (void)refreshFirst {
    [self.myTableView reloadData];
    _myTableView.showsInfiniteScrolling = _curTopics.canLoadMore;
    
    if (_curTopics.list.count == 0) {
        [self refresh];
    }
    if (!_curTopics.isLoading) {
        [self.view configBlankPage:EaseBlankPageTypeTweetPrivate hasData:(_curTopics.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
            [self sendRequest];
        }];
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
    [[NetAPIManager shareManager] request_get_friendTopicWithParams:_curTopics andBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        [self.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [self.curTopics configWithTopics:data];
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = self.curTopics.canLoadMore;
        }
        [self.view configBlankPage:EaseBlankPageTypeTweetPrivate hasData:(_curTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [self sendRequest];
        }];
    }];
}
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _curTopics.list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *curTopic = _curTopics.list[indexPath.section];
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
        [cell resetState:canShowDetail];
        cell.showMoreDetailBlock = ^(BOOL showMoreDetail) {
            if (showMoreDetail) {
                [_showMoreDetailIndexSet addIndex:indexPath.section];
            } else {
                [_showMoreDetailIndexSet removeIndex:indexPath.section];
            }
            [weakSelf.myTableView reloadData];
        };
        cell.actionButtonClickedBlock = ^(ActionType type) {
            if (type == ActionType_Delete) {
                [weakSelf deleteTopic:curTopic withIndex:indexPath.section];
            }
        };
        cell.segmentedControlBlock = ^ (NSInteger actionType,Topic *curTopic) {
            switch (actionType) {
                case 0: {
                    [self favoriteTopic:curTopic atIndex:indexPath.section];
                }
                    break;
                case 1: {
                    [self complainTopic:curTopic atIndex:indexPath.section];
                }
                    break;
                case 2: {
                    [self approveTopic:curTopic atIndex:indexPath.section];
                }
                    break;
                case 3: {
                    [self commentTopic:curTopic atIndex:indexPath.section];
                }
                    break;
                default:
                    break;
            }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0?0:kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = section == 0?0:kScaleFrom_iPhone5_Desgin(10);
    return [tableView getHeaderViewWithStr:nil andHeight:headerHeight andBlock:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Topic *curTopic = _curTopics.list[indexPath.section];
    BOOL canShowDetail = [_showMoreDetailIndexSet containsIndex:indexPath.section];
    return [TweetCell cellHeightWithObj:curTopic andTweetType:TopicTypeNormal canShowFullContent:canShowDetail];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return YES;
}

#pragma mark - Private Method
- (void)handleSegmentedControlSelected:(NSInteger)selectedIndex andTopic:(Topic *)curTopic {
    switch (selectedIndex) {
        case 0:
            break;
        case 1:
            break;
        case 2: {
            TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
            vc.curTopic = curTopic;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
            break;
        default:
            break;
    }
}

#pragma mark - Action
- (void)newTweetClicked:(id)sender {
    SendTweetViewController *vc = [[SendTweetViewController alloc] init];
    @weakify(self);
    vc.refreshBlock = ^ {
        @strongify(self);
        [self refresh];
    };
    vc.topicType = SendTopicType_ToFriendCircle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteTopic:(Topic *)topic withIndex:(NSInteger)curIndex {
    [[UIAlertView bk_showAlertViewWithTitle:@"是否确认删除?" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            @weakify(self);
            [[NetAPIManager shareManager] request_deleteTopicWithParams:topic andBlock:^(id data, NSError *error) {
                @strongify(self);
                if (data) {
                    [self.curTopics.list removeObject:topic]; //删除数据源的数据
                    [self.myTableView reloadData];            //更新列表
                    [self.view configBlankPage:EaseBlankPageTypeTweet hasData:(self.curTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                        [self sendRequest];
                    }];
                }
            }];
        }
    }] show];
}

- (void)shieldTopic:(Topic *)topic withIndex:(NSInteger)curIndex withBlock:(void (^) (id data, NSError *error))block {
    [[NetAPIManager shareManager] request_shieldTopicWithParams:topic andBlock:^(id data, NSError *error) {
        block(data,error);
    }];
}



- (void)complainTopic:(Topic *)topic atIndex:(NSInteger)dataIndex {
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"举报的同时将屏蔽此条内容" buttonTitles:@[@"骚扰信息",@"虚假信息",@"垃圾广告",@"色情相关"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index > 3) {
            return ;
        }
        @weakify(self);
        [[NetAPIManager shareManager] request_complainTopicWithParams:topic andType:index andBlock:^(id complainData, NSError *error) {
            @strongify(self);
            if (complainData) {
                [self shieldTopic:topic withIndex:dataIndex withBlock:^(id shieldData, NSError *error) {
                    if (shieldData) {
                        [self.curTopics.list removeObjectAtIndex:dataIndex];
                        [self.myTableView reloadData];
                        [self showHudTipStr:@"举报成功,等待后台处理"];
                    }
                }];
            }
        }];
    }] showInView:self.view];
}

- (void)favoriteTopic:(Topic *)topic atIndex:(NSInteger)index {
    @weakify(self);
    [[NetAPIManager shareManager] request_favoriteTopicWithParams:topic andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self showHudTipStr:topic.favorite.boolValue?@"收藏成功":@"已取消收藏"];
        }
    }];
}

- (void)approveTopic:(Topic *)topic atIndex:(NSInteger)index {
    @weakify(self);
    [[NetAPIManager shareManager] request_approveTopicWithParams:topic andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            topic.approve = topic.approve.boolValue?@0:@1;
            if (topic.approve.boolValue) {
                topic.approvenum = [NSNumber numberWithInteger:topic.approvenum.integerValue + 1];
            } else {
                topic.approvenum = [NSNumber numberWithInteger:topic.approvenum.integerValue - 1];
            }
            [self.myTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)commentTopic:(Topic *)topic atIndex:(NSInteger)index {
    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
    vc.curTopic = topic;
    vc.tweetFromCityCircle = YES;
    @weakify(self);
    vc.commentedBlock = ^() {
        @strongify(self);
        [self.myTableView reloadData];
    };
    vc.blockTopicBlock = ^() {
        @strongify(self);
        [self refresh];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
@end
