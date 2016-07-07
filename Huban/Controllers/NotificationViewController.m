//
//  NotificationViewController.m
//  Huban
//
//  Created by sean on 15/9/21.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"

@interface NotificationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataItem;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"评论通知";
    
    //right item
    UIBarButtonItem *clearItem = [UIBarButtonItem itemWithBtnTitle:@"清空" target:self action:@selector(clearClick)];
    self.navigationItem.rightBarButtonItem = clearItem;
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[NotificationCell class] forCellReuseIdentifier:kCellIdentifier_NotificationCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _dataItem = [[NSMutableArray alloc] init];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataItem.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NotificationCell cellHeightWithObj:_dataItem[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_NotificationCell forIndexPath:indexPath];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action
- (void)clearClick {
    NSLog(@"清空");
}
@end
