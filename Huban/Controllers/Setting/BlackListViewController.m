//
//  BlackListViewController.m
//  Huban
//
//  Created by sean on 15/11/20.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "BlackListViewController.h"
#import "ODRefreshControl.h"
#import "ToUserCell.h"
#import "UserInfoViewController.h"

@interface BlackListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *refreshControl;

@property (strong, nonatomic) Contacts *curContacts;
@end

@implementation BlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"黑名单";
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        [tableview registerClass:[ToUserCell class] forCellReuseIdentifier:kCellIdentifier_ToUserCell];
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableview.sectionIndexBackgroundColor = [UIColor clearColor];
        tableview.contentInset = UIEdgeInsetsMake(0, 0, kMyTabbarControl_Height, 0);
        tableview.sectionIndexColor = SYSBACKGROUNDCOLOR_BLUE;
        [self.view addSubview:tableview];
        [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableview;
    });
    _myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, .1f)];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    _curContacts = [[Contacts alloc] init];
    
    [self refresh];
}

- (void)refresh {
    if (_curContacts.isLoading) {
        return;
    }
    _curContacts.isLoading = YES;
    @weakify(self);
    [[NetAPIManager shareManager] request_contact_blackListWithBlock:^(id data, NSError *error) {
        @strongify(self);
        [self.refreshControl endRefreshing];
        self.curContacts.isLoading = NO;
        if (data) {
            NSLog(@"%@",data);
            NSArray *dataItem = [NSObject arrayFromJSON:[data objectForKey:@"list"] ofObjects:@"Contact"];
            [self.curContacts configArray:dataItem];
            [self.myTableView reloadData];
        }
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _curContacts.allContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ToUserCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ToUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToUserCell forIndexPath:indexPath];
    Contact *curContact = _curContacts.allContacts[indexPath.row];
    cell.contact = curContact;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *curContact = _curContacts.allContacts[indexPath.row];
    UserInfoViewController *vc = [[UserInfoViewController alloc] init];
    vc.userCode = curContact.contactcode;
    vc.infoType = UserInfoTypeNormal;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
