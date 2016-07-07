//
//  Contact__RootViewController.m
//  Huban
//
//  Created by sean on 15/7/26.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "Contact_RootViewController.h"
#import "TitleLeftImageCell.h"
#import "ToUserCell.h"
#import "AddUserViewController.h"
#import "UserInfoViewController.h"
#import "UserGroupViewController.h"
#import "ODRefreshControl.h"

@interface Contact_RootViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *indexTitleArray;
@property (strong, nonatomic) Contacts *curContacts;
@property (strong, nonatomic) ODRefreshControl *refreshControl;
@end

@implementation Contact_RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通讯录";
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        [tableview registerClass:[TitleLeftImageCell class] forCellReuseIdentifier:kCellIdentifier_TitleLeftImageCell];
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
    _indexTitleArray = [[NSMutableArray alloc] initWithObjects:@" ", nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refresh];
}

- (void)refresh {
    if (_curContacts.isLoading) {
        return;
    }
    _curContacts.isLoading = YES;
    //获取本地的所有好友记录
    NSArray *originArray = [[DataBaseManager shareInstance] queryContacts];
    [self reloadDataSource:originArray];
    
    //userDefault
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    @weakify(self);
    [[NetAPIManager shareManager] request_get_contactListVersionWithBlock:^(id versionData, NSError *error) {
        @strongify(self);
        [self.refreshControl endRefreshing];
        self.curContacts.isLoading = NO;
        if (versionData) {
            NSNumber *curVersion = versionData[@"value"];
            NSNumber *oldVersion = [userDefaults objectForKey:kContactListVersion];
            if (oldVersion >= curVersion) { //如果本地版本是最新,就不需要更新
                [self.curContacts configArray:originArray]; //获取本地数据
                [self.curContacts resortIndexArray];
                [self resoltContacts];
            } else { //从服务器获取最新好友列表
                [[NetAPIManager shareManager] request_get_contactListWithParams:_curContacts andBlock:^(id data, NSError *error) {
                    if (data) {
                        NSArray *contactsArray = [NSObject arrayFromJSON:data[@"list"] ofObjects:@"Contact"];
                        //更新本地版本号
                        [userDefaults setObject:curVersion forKey:kContactListVersion];
                        [userDefaults synchronize];
                        //后台删除本地库存
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            for (Contact *curContact in originArray) {
                                [[DataBaseManager shareInstance] deleteContact:curContact];
                            }
                        });
                        //保存新的信息
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            for (Contact *curContact in contactsArray) {
                                [[DataBaseManager shareInstance] saveContact:curContact];
                            }
                        });
                        //更新界面
                        [self reloadDataSource:contactsArray];
                    }
                }];
            }
        }
    }];
}

- (void)resoltContacts {
    [_indexTitleArray removeAllObjects];
    [_indexTitleArray addObject:@" "];
    [_indexTitleArray addObjectsFromArray:_curContacts.indexLetterArray];
    [self.myTableView reloadData];
}

- (void)reloadDataSource:(NSArray *)dataItems {
    [self.curContacts configArray:dataItems];
    [self.curContacts resortIndexArray];
    [self resoltContacts];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _indexTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0?1:[_curContacts contactInLetter:_indexTitleArray[section]].count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexTitleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _indexTitleArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0?[TitleLeftImageCell cellHeight]:[ToUserCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TitleLeftImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleLeftImageCell forIndexPath:indexPath];
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    [cell setTitle:@"添加好友" bigIcon:@"addUser"];
                    break;
                case 1:
                    [cell setTitle:@"好友分组" bigIcon:@"friendGroup"];
                    break;
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    ToUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToUserCell forIndexPath:indexPath];
    Contact *curContact = [_curContacts contactInLetter:_indexTitleArray[indexPath.section]][indexPath.row];
    cell.contact = curContact;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        BaseViewController *vc;
        switch (indexPath.row) {
            case 0:
                vc = [[AddUserViewController alloc] init];
                break;
            case 1:
                vc = [[UserGroupViewController alloc] init];
                break;
        }
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        Contact *curContact = [_curContacts contactInLetter:_indexTitleArray[indexPath.section]][indexPath.row];
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.userCode = curContact.contactcode;
        vc.infoType = UserInfoTypeNormal;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
@end
