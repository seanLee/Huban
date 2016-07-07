//
//  FriendsCircleViewController.m
//  Huban
//
//  Created by sean on 15/8/18.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "FriendsCircleViewController.h"
#import "TweetCell.h"
#import "CircleDetailViewController.h"
#import "UserInfoViewController.h"

@interface FriendsCircleViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) NSMutableIndexSet *showMoreDetailIndexSet;
@end

@implementation FriendsCircleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"生活圈";
    
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
        tableview;
    });
    _dataArray = [NSMutableArray new]; //保存数据
    _showMoreDetailIndexSet = [[NSMutableIndexSet alloc] init]; //保存用户显示状态
    
    [self loadData];
}

- (void)loadData {
    for (int i = 0; i < 10; i ++) {
        Tweet *tweet = [[Tweet alloc] init];
        User *curUser = [User new];
        curUser.name = @"sean";
        curUser.gender = @(i%2);
        curUser.avatar = @"http://img5.duitang.com/uploads/item/201401/22/20140122112618_ZXznW.thumb.700_0.jpeg";
        curUser.charactLevel = @(i);
        tweet.owner = curUser;
        tweet.created_at = [NSDate dateFromString:@"2015-05-01" withFormat:@"yyyy-MM-dd"];
        tweet.content = @"苹果公司（Apple Inc. ）是美国的一家高科技公司。由史蒂夫·乔布斯、斯蒂夫·沃兹尼亚克和罗·韦恩(Ron Wayne)等三人于1976年4月1日创立，并命名为美国苹果电脑公司（Apple Computer Inc. ）， 2007年1月9日更名为苹果公司，总部位于加利福尼亚州的库比蒂诺。苹果公司1980年12月12日公开招股上市，2012年创下6235亿美元的市值记录，截至2014年6月，苹果公司已经连续三年成为全球市值最大公司。苹果公司在2014年世界500强排行榜中排名第15名。2013年9月30日，在宏盟集团的“全球最佳品牌”报告中，苹果公司超过可口可乐成为世界最有价值品牌。2014年，苹果品牌超越谷歌（Google），成为世界最具价值品牌。";
//        tweet.content = @"苹果公司（Apple Inc. ）是美国的一家高科技公司。由史蒂夫·乔布斯、斯蒂夫·沃兹尼亚克和罗·韦恩(Ron Wayne)等三人于1976年4月1日创立，并命名为美国苹果电脑公司（Apple Computer Inc. ）， 2007年1月9日更名为苹果公司，总部位于加利福尼亚州";
        tweet.location = @"美国加利福尼亚州库比蒂诺市";
        for (int j = 0; j < i; j++) {
            [tweet.tweetImages addObject:@"http://ww1.sinaimg.cn/bmiddle/bfc243a3jw1ev79sj83woj20vv16hh2d.jpg"];
            User *commentUser = [User new];
            commentUser.avatar = @"http://imga1.pic21.com/bizhi/140206/07205/s24.jpg";
            Comment *newComment = [Comment new];
            newComment.owner = commentUser;
            [tweet.comment_list addObject:newComment];
        }
        for (int k = 0; k < 17 ;k++) {
            User *newUser = [User new];
            newUser.avatar = @"http://ww4.sinaimg.cn/bmiddle/69c76a90jw1ev77en43ltj21jk111qcs.jpg";
            [tweet.likes_users addObject:newUser];
        }
        [_dataArray addObject:tweet];
    }
    [_myTableView reloadData];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *curTweet = _dataArray[indexPath.section];
    __weak typeof(self) weakSelf = self;
    TweetCell *cell;
    BOOL canShowDetail = [_showMoreDetailIndexSet containsIndex:indexPath.section];
    if (curTweet.tweetImages.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetCell forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetCell_Media forIndexPath:indexPath];
    }
    cell.curTweet = curTweet;
    [cell resetState:canShowDetail];
    cell.showMoreDetailBlock = ^(BOOL showMoreDetail) {
        if (showMoreDetail) {
            [_showMoreDetailIndexSet addIndex:indexPath.section];
        } else {
            [_showMoreDetailIndexSet removeIndex:indexPath.section];
        }
        [weakSelf.myTableView reloadData];
    };
    cell.userInfoBlock = ^(User *curUser) {
        UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] init];
        userInfoVC.curUser = curUser;
        [weakSelf.navigationController pushViewController:userInfoVC animated:YES];
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
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
    Tweet *curTweet = _dataArray[indexPath.section];
    BOOL canShowDetail = [_showMoreDetailIndexSet containsIndex:indexPath.section];
    return [TweetCell cellHeightWithObj:curTweet canShowFullContent:canShowDetail];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tweet *curTweet = _dataArray[indexPath.section];
    CircleDetailViewController *vc = [[CircleDetailViewController alloc] init];
    vc.curTweet = curTweet;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
