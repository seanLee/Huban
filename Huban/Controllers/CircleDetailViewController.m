//
//  CircleDetailViewController.m
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CircleDetailViewController.h"
#import "TweetDetailCell.h"
#import "TweetLikesCell.h"
#import "TweetCommentsCell.h"

@interface CircleDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation CircleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评论内容";
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
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
        tableview;
    });
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            TweetDetailCell *cell;
            if (_curTweet.tweetImages.count == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetDetailCell forIndexPath:indexPath];
                cell.curTweet = _curTweet;
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetDetailCell_Media forIndexPath:indexPath];
                cell.curTweet = _curTweet;
            }
            return cell;
        }
            break;
        case 1: {
            TweetLikesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIentifier_TweetLikesCell forIndexPath:indexPath];
            cell.curTweet = _curTweet;
            return cell;
        }
            break;
        default: {
            TweetCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetCommentsCell forIndexPath:indexPath];
            cell.curTweet = _curTweet;
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellHeight = 0;
    if (indexPath.row == 0) {
        cellHeight = [TweetDetailCell cellHeightWithObj:_curTweet];
    } else if (indexPath.row == 1) {
        cellHeight = [TweetLikesCell cellHeightWithObj:_curTweet];
    } else if (indexPath.row == 2) {
        cellHeight = [TweetCommentsCell cellHeightWithObj:_curTweet];
    }
    return cellHeight;
}
@end
