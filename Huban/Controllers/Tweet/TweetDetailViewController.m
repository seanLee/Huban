//
//  CircleDetailViewController.m
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "TweetDetailCell.h"
#import "TweetLikesCell.h"
#import "TweetCommentsCell.h"
#import "TweetLikersViewController.h"
#import "UserInfoViewController.h"
#import "UIMessageInputView.h"
#import "TopicComments.h"
#import "ODRefreshControl.h"
#import "SVPullToRefresh.h"
#import "TopicLikes.h"

@interface TweetDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIMessageInputViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIMessageInputView *myMsgInputView;
@property (strong, nonatomic) ODRefreshControl *refreshControl;


@property (strong, nonatomic) TopicComments *topicComments;
@property (strong, nonatomic) TopicLikes *topicLikes;
@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评论内容";
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        [tableview registerClass:[TweetDetailCell class] forCellReuseIdentifier:kCellIentifier_TweetDetailCell];
        [tableview registerClass:[TweetDetailCell class] forCellReuseIdentifier:kCellIentifier_TweetDetailCell_Media];
        [tableview registerClass:[TweetLikesCell class] forCellReuseIdentifier:kCellIentifier_TweetLikesCell];
        [tableview registerClass:[TweetCommentsCell class] forCellReuseIdentifier:kCellIdentifier_TweetCommentsCell];
        tableview.backgroundColor = [UIColor whiteColor];
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
    
    //初始化键盘
    _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeComment];
    _myMsgInputView.feedbackComment = nil;
    _myMsgInputView.isAlwaysShow = YES;
    _myMsgInputView.delegate = self;
    
    _topicComments = [[TopicComments alloc] init];
    _topicComments.commentType = _tweetFromCityCircle?CommentType_CityCircle:CommentType_Normal;
    _topicComments.topicCode = _curTopic.topiccode;
    
    _topicLikes = [[TopicLikes alloc] init];
    _topicLikes.topicCode = _curTopic.topiccode;
    
    [self refreshFirst];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_myMsgInputView) {
        [_myMsgInputView prepareToShow];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_myMsgInputView) {
        [_myMsgInputView prepareToDismiss];
    }
}

- (void)dealloc{
    _myTableView.delegate = nil;
    _myTableView.dataSource = nil;
}

- (void)refreshFirst {
    [self.myTableView reloadData];
    _myTableView.showsInfiniteScrolling = _topicComments.canLoadMore;
    if (_topicComments.list.count == 0) {
        [self refresh];
    }
}

- (void)refresh {
    if (_topicComments.isLoading) {
        return;
    }
    _topicComments.willLoadMore = NO;
    _topicComments.curPage = 0;
    
    _topicLikes.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore {
    if (_topicComments.isLoading || !_topicComments.canLoadMore) {
        return;
    }
    _topicComments.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest {
    if (_topicComments.list.count <= 0) {
        [self.view beginLoading];
    }
    @weakify(self);
    //获取评论
    [[NetAPIManager shareManager] request_get_commentsOfTopicWithParams:_topicComments andBlock:^(id commentsData, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        if (commentsData) {
            NSLog(@"评论列表:%@",commentsData);
            [self.topicComments configWithComments:commentsData];
            self.curTopic.comment_list = self.topicComments.list;
            [self.myTableView reloadData];
            self.myTableView.showsInfiniteScrolling = self.topicComments.canLoadMore;
        }
    }];
    //获取点赞的列表
    [[NetAPIManager shareManager] request_get_likesToTopicWithParams:_topicLikes andBlock:^(id likesData, NSError *error) {
        @strongify(self);
        [self.view endLoading];
        [self.refreshControl endRefreshing];
        if (likesData) {
            NSLog(@"点赞列表:%@",likesData);
            [self.topicLikes configWithLikes:likesData];
            self.curTopic.likes_users = self.topicLikes.list;
            [self.myTableView reloadData];
        }
    }];
}


- (void)getCommentList {
   
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRow = 1;
    if (_curTopic.approvenum.integerValue > 0) { //如果有点赞信息
        numberOfRow += 1;
    }
    if (_curTopic.commentnum.integerValue > 0) { //如果有评论信息
        numberOfRow += 1;
    }
    return numberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0: {
            TweetDetailCell *cell;
            if ([_curTopic topicMedium].count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetDetailCell forIndexPath:indexPath];
                cell.curTopic = _curTopic;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetDetailCell_Media forIndexPath:indexPath];
                cell.curTopic = _curTopic;
            }
            cell.headerClickedBlock = ^(User *curUser){
                if (weakSelf.headerClickedBlock) {
                    weakSelf.headerClickedBlock(curUser);
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
                        [self commentToComment:nil];
                    }
                        break;
                    default:
                        break;
                }
            };
            return cell;
        }
            break;
        case 1: {
            if ([self noneOfComments]) { //如果有点赞,但是没有评论
                TweetLikesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetLikesCell forIndexPath:indexPath];
                cell.showMoreLikerBlock = ^(Topic *curTopic) {
                    TweetLikersViewController *vc = [[TweetLikersViewController alloc] init];
                    vc.curTopic = curTopic;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                cell.userClickedBlock = ^(TopicLike *likeUser) {
                    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
                    vc.userCode = likeUser.usercode;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                };
                cell.curTopic = _curTopic;
                return cell;
            } else {
                TweetCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetCommentsCell forIndexPath:indexPath];
                cell.curTopic = _curTopic;
                @weakify(self);
                cell.commentButtonClicked = ^(TopicComment *feedback) {
                    @strongify(self);
                    [self commentToComment:feedback];
                };
                cell.deleteCommentBlock = ^(TopicComment *deleteComment) {
                    @strongify(self);
                    [self.myMsgInputView isAndResignFirstResponder];
                    [self deleteComment:deleteComment];
                };
                cell.didTapLinkBlock = ^(NSDictionary *dict) {
                    @strongify(self);
                    [self handleTapLinkWithDict:dict];
                };
                return cell;
            }
        }
            break;
        default: {
            TweetCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetCommentsCell forIndexPath:indexPath];
            cell.curTopic = _curTopic;
            @weakify(self);
            cell.commentButtonClicked = ^(TopicComment *feedback) {
                @strongify(self);
                [self commentToComment:feedback];
            };
            cell.deleteCommentBlock = ^(TopicComment *deleteComment) {
                @strongify(self);
                [self.myMsgInputView isAndResignFirstResponder];
                [self deleteComment:deleteComment];
            };
            cell.didTapLinkBlock = ^(NSDictionary *dict) {
                @strongify(self);
                [self handleTapLinkWithDict:dict];
            };
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetDetailCell cellHeightWithObj:_curTopic];
    } else if (indexPath.row == 1) {
        if ([self noneOfComments]) {
            cellHeight = [TweetLikesCell cellHeightWithObj:_curTopic];
        } else {
            cellHeight = [TweetCommentsCell cellHeightWithObj:_curTopic];
        }
    } else if (indexPath.row == 2) {
        cellHeight = [TweetCommentsCell cellHeightWithObj:_curTopic];
    }
    return cellHeight;
}

- (BOOL)noneOfComments {
    return self.curTopic.approvenum.integerValue > 0;
}

#pragma mark - Private Method
- (void)commentToComment:(TopicComment *)feedBackComment {
    _myMsgInputView.feedbackComment = feedBackComment;
    [_myMsgInputView notAndBecomeFirstResponder];
}

- (void)deleteComment:(TopicComment *)deleteComment {
    @weakify(self);
    [[NetAPIManager shareManager] request_delete_commentOfTopicWithParams:deleteComment andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            [self.topicComments.list removeObject:deleteComment];
            self.curTopic.comment_list = self.topicComments.list;
            self.curTopic.commentnum = @(self.curTopic.commentnum.intValue - 1);
            [self.myTableView reloadData];
            if (self.commentedBlock) {
                self.commentedBlock();
            }
        }
    }];
}

- (void)favoriteTopic:(Topic *)topic atIndex:(NSInteger)index {
    @weakify(self);
    [[NetAPIManager shareManager] request_favoriteTopicWithParams:topic andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            [self.myTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            [self showHudTipStr:topic.favorite.boolValue?@"收藏成功":@"已取消收藏"];
        }
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
                        if (self.blockTopicBlock) {
                            self.blockTopicBlock();
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                        [self showHudTipStr:@"举报成功,等待后台处理"];
                    }
                }];
            }
        }];
    }] showInView:self.view];
}

- (void)shieldTopic:(Topic *)topic withIndex:(NSInteger)curIndex withBlock:(void (^) (id data, NSError *error))block {
    [[NetAPIManager shareManager] request_shieldTopicWithParams:topic andBlock:^(id data, NSError *error) {
        block(data,error);
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
            [self refresh];
            [self.myTableView reloadData];
        }
    }];
}

- (void)handleTapLinkWithDict:(NSDictionary *)dict {
    NSString *userCode = dict[@"usercode"];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.userCode = userCode;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIMessageInputViewDelegate
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text {
    TopicComment *comment = [[TopicComment alloc] initWithTopic:self.curTopic];
    comment.commentcontent = text;
    comment.feedbackcode = inputView.feedbackComment.usercode;
    @weakify(self);
    [[NetAPIManager shareManager] request_get_commentToTopicWithParams:comment andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            if ([data[@"state"] integerValue] == 1) {
                self.curTopic.commentnum = @(self.curTopic.commentnum.intValue + 1);
                if (self.commentedBlock) {
                    self.commentedBlock();
                }
                [self refresh]; //刷新界面
            }
        }
    }];
    //取消键盘
    [_myMsgInputView isAndResignFirstResponder];
}

- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom {
    UIEdgeInsets contentInsets= UIEdgeInsetsMake(0.0, 0.0, MAX(CGRectGetHeight(inputView.frame), heightToBottom), 0.0);;
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    //调整内容
    static BOOL keyboard_is_down = YES;
    static CGPoint keyboard_down_ContentOffset;
    static CGFloat keyboard_down_InputViewHeight;
    if (heightToBottom > CGRectGetHeight(inputView.frame)) {
        if (keyboard_is_down) {
            keyboard_down_ContentOffset = self.myTableView.contentOffset;
            keyboard_down_InputViewHeight = CGRectGetHeight(inputView.frame);
        }
        keyboard_is_down = NO;
        
        CGPoint contentOffset = keyboard_down_ContentOffset;
        CGFloat spaceHeight = MAX(0, CGRectGetHeight(self.myTableView.frame) - self.myTableView.contentSize.height - keyboard_down_InputViewHeight);
        contentOffset.y += MAX(0, heightToBottom - keyboard_down_InputViewHeight - spaceHeight);
        [UIView animateWithDuration:0.25 delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.myTableView.contentOffset = contentOffset;
        } completion:nil];
    }else{
        keyboard_is_down = YES;
    }
}

#pragma mark - ScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == _myTableView) {
        [_myMsgInputView isAndResignFirstResponder];
    }
}
@end
