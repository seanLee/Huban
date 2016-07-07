//
//  TweetLikersViewController.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TweetLikersViewController.h"
#import "ToUserCell.h"
#import "UserInfoViewController.h"

@interface TweetLikersViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation TweetLikersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:@"赞(%@)",_curTopic.approvenum];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ToUserCell class] forCellReuseIdentifier:kCellIdentifier_ToUserCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
}

#pragma mark - TabelView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _curTopic.likes_users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ToUserCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToUserCell forIndexPath:indexPath];
//    cell.curToUser = _curTopic.likes_users[indexPath.row];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    User *curUser = _curTopic.likes_users[indexPath.row];
    vc.userCode = curUser.usercode;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
