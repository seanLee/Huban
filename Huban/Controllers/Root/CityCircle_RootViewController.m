//
//  CityCircle__RootViewController.m
//  Huban
//
//  Created by sean on 15/7/26.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CityCircle_RootViewController.h"
#import "TweetCell.h"
#import "CityChosenViewController.h"
#import "SendTweetViewController.h"
#import "UserInfoViewController.h"
#import "TweetDetailViewController.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "RDVTabBarController.h"
#import "TranspondViewController.h"
#import "BaseNavigationController.h"
#import "EaseSDKHelper.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface CityCircle_RootViewController () <UITableViewDataSource, UITableViewDelegate> {
    CGFloat _oldPanOffsetY;
}
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *refreshControl;
@property (strong, nonatomic) UIBarButtonItem *sendTweetItem;

@property (strong, nonatomic) NSMutableIndexSet *showMoreDetailIndexSet;

//@property (strong, nonatomic) Region *currentRegion;    //用户当前所处的位置
@property (strong, nonatomic) NSString *selectedRegionCode;   //用户选择的位置
@property (strong, nonatomic) Topics *curTopics;
@property (assign, nonatomic) NSInteger curPage;

@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation CityCircle_RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sendTweetItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_newTweet"] style:UIBarButtonItemStylePlain target:self action:@selector(newTweetClicked)];
    _sendTweetItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = _sendTweetItem;

    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds];
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
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, kMyTabbarControl_Height, 0);
            tableview.contentInset = insets;
            tableview.scrollIndicatorInsets = insets;
            
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
    
    _showMoreDetailIndexSet = [NSMutableIndexSet indexSet];
    
    self.selectedRegionCode = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectedCityCode];
    if ([self selectedRegion]) {
        [self initRefresh];
    } else { //用户没有选择过城市
        //获取当前登录用户的详细位置
        [self getLocationStr];
    }
}

#pragma mark - Set
- (void)setSelectedRegionCode:(NSString *)selectedRegionCode {
    _selectedRegionCode = selectedRegionCode;
    if (selectedRegionCode && ![selectedRegionCode isEmpty]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:selectedRegionCode forKey:kUserSelectedCityCode];
        [userDefaults synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //隐藏tabbar
    NSInteger diff = self.myTableView.contentSize.height - self.myTableView.contentOffset.y;
    if (diff == kScreen_Height - 64.f) { //如果用户滑到最底下
        [self.rdv_tabBarController setTabBarHidden:YES animated:NO];
    }
}

- (void)tabBarItemClicked {
    [self refresh];
    [self getLocationStr];
}

- (UIView *)customerTitleView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.f, 30.f)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [titleView addGestureRecognizer:tap];
    
    
    UILabel *regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30.f)];
    regionLabel.font = [UIFont boldSystemFontOfSize:16.f];
    regionLabel.textColor = [UIColor whiteColor];
    regionLabel.text = [self selectedRegion].cityname;
    //resize
    CGFloat textWidth = [[self selectedRegion].cityname getWidthWithFont:[UIFont boldSystemFontOfSize:16.f] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 30.f)];
    [regionLabel setWidth:textWidth];
    
    CGFloat indicatorWidth = 10.f;
    CGFloat indicatorHeight = 10.f;
    
    UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectMake(textWidth + 2, 10.f, indicatorWidth, indicatorHeight)];
    //indicator
    //path
    UIBezierPath *indicatorPath = [[UIBezierPath alloc] init];
    [indicatorPath moveToPoint:CGPointMake(0, indicatorHeight/2)];
    [indicatorPath addLineToPoint:CGPointMake(indicatorWidth/2, indicatorHeight)];
    [indicatorPath addLineToPoint:CGPointMake(indicatorWidth, indicatorHeight/2)];
    
    CAShapeLayer *indicatorLayer = [[CAShapeLayer alloc] init];
    indicatorLayer.path = indicatorPath.CGPath;
    indicatorLayer.fillColor = [UIColor whiteColor].CGColor;
    indicatorLayer.position = CGPointMake(0, -2.f);
    [indicatorView.layer addSublayer:indicatorLayer];
    
    [titleView addSubview:regionLabel];
    [titleView addSubview:indicatorView];
    [titleView setWidth:textWidth + 2 + indicatorWidth];
    return titleView;
}

- (void)getLocationStr {
    if (_hud.hidden == NO) {
        [_hud hide:YES];
    }
    if (!self.selectedRegionCode || [self.selectedRegionCode isEmpty]) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.mode = MBProgressHUDModeIndeterminate;
        _hud.labelText = @"正在获取您的位置信息";
        _hud.margin = 10.f;
        _hud.removeFromSuperViewOnHide = YES;
        //重新定位
        @weakify(self);
        [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
            @strongify(self);
            [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:userLocation.location.coordinate.longitude andLatitude:userLocation.location.coordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
                [self.hud hide:YES];
                [self getLocationStr:location];
            }];
        }];
    }
}

#pragma makr - Provite
- (void)getLocationStr:(BMKReverseGeoCodeResult *)placeMarks {
    NSString *cityName = placeMarks.addressDetail.city; //获取到坐标的城市名称
    self.selectedRegionCode = [[DataBaseManager shareInstance] regionForFullName:cityName].citycode;
    
    [self initRefresh];
}

- (void)initRefresh {
    self.navigationItem.titleView = [self customerTitleView];
    
    //set the data
    self.curTopics = [[Topics alloc] init];
    self.curTopics.curRegion = [self selectedRegion];
    self.curTopics.curPage = _curPage;
    [self refreshFirst];
    
    self.sendTweetItem.enabled = YES;
}
#pragma mark - Refresh
- (void)refreshFirst {
    [self.myTableView reloadData];
//    if (self.myTableView.contentSize.height <= CGRectGetHeight(self.myTableView.bounds) - 50) {
//        [self hideToolBar:NO];
//    }
    
    _myTableView.showsInfiniteScrolling = _curTopics.canLoadMore;
    
    if (_curTopics.list.count == 0) {
        [self refresh];
    }
    if (!_curTopics.isLoading) {
        [self.view configBlankPage:EaseBlankPageTypeTweet hasData:(_curTopics.list.count > 0) hasError:NO reloadButtonBlock:^(id sender) {
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
    NSString *cityCode = self.curTopics.curRegion.citycode;
    if (cityCode && ![cityCode isEmpty]) { //如果位置信息加载完毕
        _sendTweetItem.enabled = NO;
        @weakify(self);
        [[NetAPIManager shareManager] request_get_cityCircleTopicWithParams:_curTopics andBlock:^(id data, NSError *error) {
            @strongify(self);
            self.sendTweetItem.enabled = YES;
            [self.view endLoading];
            [self.refreshControl endRefreshing];
            [self.myTableView.infiniteScrollingView stopAnimating];
            if (data) {
                [self.curTopics configWithTopics:data];
                [self.myTableView reloadData];
                self.myTableView.showsInfiniteScrolling = self.curTopics.canLoadMore;
            }
            [self.view configBlankPage:EaseBlankPageTypeTweet hasData:(_curTopics.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
                [self sendRequest];
            }];
        }];
    } else {
        [self showHudTipStr:@"获取城市信息错误,请重新获取信息"];
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        [self.myTableView.infiniteScrollingView stopAnimating];
    }
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
    @weakify(self);
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
        cell.showMoreDetailBlock = ^ (BOOL showMoreDetail) {
            @strongify(self);
            if (showMoreDetail) {
                [self.showMoreDetailIndexSet addIndex:indexPath.section];
            } else {
                [self.showMoreDetailIndexSet removeIndex:indexPath.section];
            }
            [self.myTableView reloadData];
        };
        cell.actionButtonClickedBlock = ^ (ActionType type) {
            @strongify(self);
            if (type == ActionType_Delete) {
                [self deleteTopic:curTopic withIndex:indexPath.section];
            }
        };
        cell.segmentedControlBlock = ^ (NSInteger actionType,Topic *curTopic) {
            @strongify(self);
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
        cell.userInfoBlock = ^ (NSString *userCode) {
            @strongify(self);
            UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
            userInfoVC.infoType = UserInfoTypeNormal;
            userInfoVC.userCode = userCode;
            [self.navigationController pushViewController:userInfoVC animated:YES];
        };
        cell.transpondBlock = ^ (UIImage *transpondImage) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    __weak typeof(self) weakSelf = self;
//    Topic *curTopic = _curTopics.list[indexPath.section];
//    TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
//    vc.commentedBlock = ^(){
//        [weakSelf.myTableView reloadData];
//    };
//    vc.headerClickedBlock = ^(User *curUser) {
//        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
//        userInfoVC.infoType = UserInfoTypeNormal;
//        userInfoVC.userCode = curUser.usercode;
//        [weakSelf.navigationController pushViewController:userInfoVC animated:YES];
//    };
//    vc.curTopic = curTopic;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (void)handleTap:(UIGestureRecognizer *)recognizer {
    CityChosenViewController *vc = [[CityChosenViewController alloc] init];
    vc.type = RegionType_CityCircle;
    @weakify(self);
    vc.selectedRegionBlock = ^(Region *selectedRegion) {
        @strongify(self);
        self.curTopics.curRegion = selectedRegion; // topicsRegion
        self.selectedRegionCode = selectedRegion.citycode;
        self.navigationItem.titleView = [self customerTitleView]; //titleView;
        [self refresh];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)newTweetClicked {
    SendTweetViewController *vc = [[SendTweetViewController alloc] init];
    vc.curRegion = self.selectedRegion;
    vc.topicType = SendTopicType_ToCityCircle;
    @weakify(self);
    vc.refreshBlock = ^ {
        @strongify(self);
        [self refresh];
    };
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
    vc.commentedBlock = ^(){
        @strongify(self);
        [self.myTableView reloadData];
    };
    vc.blockTopicBlock = ^{
        @strongify(self);
        [self refresh];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        _oldPanOffsetY = [scrollView.panGestureRecognizer translationInView:scrollView.superview].y;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    _oldPanOffsetY = 0;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.contentSize.height <= CGRectGetHeight(scrollView.bounds)-50) {
//        [self hideToolBar:NO];
//        return;
//    }else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged){
//        CGFloat nowPanOffsetY = [scrollView.panGestureRecognizer translationInView:scrollView.superview].y;
//        CGFloat diffPanOffsetY = nowPanOffsetY - _oldPanOffsetY;
//        CGFloat contentOffsetY = scrollView.contentOffset.y;
//        if (ABS(diffPanOffsetY) > 50.f) {
//            [self hideToolBar:(diffPanOffsetY < 0.f && contentOffsetY > 0)];
//            _oldPanOffsetY = nowPanOffsetY;
//        }
//    }
//}

//- (void)hideToolBar:(BOOL)hide {
//    if (hide != self.rdv_tabBarController.tabBarHidden) {
//        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (hide? (_curTopics.canLoadMore? 60.0: 0.0):CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)), 0.0);
//        self.myTableView.contentInset = contentInsets;
//        [self.rdv_tabBarController setTabBarHidden:hide animated:YES];
//    }
//}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self.refreshControl beginRefreshing];
    [self refresh];
}

#pragma mark - Private
- (Region *)selectedRegion {
    return [[DataBaseManager shareInstance] regionForCityCode:self.selectedRegionCode];
}

#pragma mark - Transpond
- (void)transpondImageMessage:(UIImage *)transpondImage andToUser:(NSString *)toUser {
    [EaseSDKHelper sendImageMessageWithImage:transpondImage
                                          to:toUser
                                 messageType:eMessageTypeChat
                           requireEncryption:NO
                                  messageExt:nil
                                    progress:nil];
}
@end
