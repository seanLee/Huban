//
//  AddUserViewController.m
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AddUserViewController.h"
#import "CollectionView_TableCell.h"
#import "AddUserRequestCell.h"
#import "UserInfoViewController.h"
#import "ApplicationAuthViewController.h"

@interface AddUserViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UISearchDisplayController *myDisplayController;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *dataItems;

@property (strong, nonatomic) Users *curUsers;
@property (strong, nonatomic) ConfirmLogs *curConfirmLogs;
@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"添加好友";
    
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableview registerClass:[CollectionView_TableCell class] forCellReuseIdentifier:kCellIdentifier_CollectionView_TableCell];
        [tableview registerClass:[AddUserRequestCell class] forCellReuseIdentifier:kCellIdentifier_AddCustomerRequestCell];
        [self.view addSubview:tableview];
        [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableview;
    });
    _searchBar = ({
        UISearchBar *searchBar = [[UISearchBar alloc] init];
        [searchBar sizeToFit];
        searchBar.placeholder = @"请输入呼伴号/手机号";
        searchBar.delegate = self;
        [searchBar insertBGColor:SYSBACKGROUNDCOLOR_DEFAULT];
        searchBar;
    });
    //searchBar
    _myTableView.tableHeaderView = _searchBar;
    _myDisplayController = ({
        UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        [searchVC.searchResultsTableView registerClass:[AddUserRequestCell class] forCellReuseIdentifier:kCellIdentifier_AddCustomerRequestCell];
        searchVC.delegate = self;
        searchVC.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC;
    });
    
    _curUsers = [[Users alloc] init];
    _curConfirmLogs = [[ConfirmLogs alloc] init];
    
    _dataItems = [[NSMutableArray alloc] init];
    [self getConfirmList];
}

- (void)getConfirmList {
    [[NetAPIManager shareManager] request_get_confirmsWithParams:_curConfirmLogs andBlock:^(id data, NSError *error) {
        if (data) {
            NSLog(@"好友申请:%@",data);
        }
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return _curUsers.list.count;
    } else {
        if (section == 1) {
            return _dataItems.count;
        }
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return 0;
    }
    return section == 0?20.f:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20.f)];
    footer.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectZero];
    addButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    addButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [addButton setTitle:@"添加好友" forState:UIControlStateNormal];
    [addButton setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:addButton];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectZero];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    clearButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [clearButton setTitle:@"清空列表" forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:clearButton];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footer).offset(kPaddingLeftWidth);
        make.top.bottom.equalTo(footer);
        make.width.mas_equalTo(80);
    }];
    
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        make.top.bottom.equalTo(footer);
        make.width.mas_equalTo(80);
    }];
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return [AddUserRequestCell cellHeight];
    } else {
        if (indexPath.section == 0) {
            return [CollectionView_TableCell cellHeight];
        }
        return [AddUserRequestCell cellHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _myDisplayController.searchResultsTableView) {
        AddUserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCustomerRequestCell forIndexPath:indexPath];
        cell.curUser = _curUsers.list[indexPath.row];
        cell.state = AddedUserStateNewAdded;
        @weakify(self);
        cell.actionClicked = ^(User *curUser) {
            @strongify(self);
            [self handleActionWithUser:curUser];
        };
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    } else {
        if (indexPath.section == 0) {
            CollectionView_TableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CollectionView_TableCell forIndexPath:indexPath];
            return cell;
        }
        AddUserRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AddCustomerRequestCell forIndexPath:indexPath];
        cell.state = indexPath.row;
        User *newUser = [User new];
        newUser.userlogourl = @"http://img.88pets.com/Images/editor/2013-09/20130911121417fw1038.jpg";
        newUser.username = @"SeanLee";
        cell.curUser = newUser;
        
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return YES;
    } else {
        if (indexPath.section == 2) {
            return YES;
        }
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == _myDisplayController.searchResultsTableView) {
        User *curUser = _curUsers.list[indexPath.row];
        UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        vc.fromSearchVC = YES;
        vc.userCode = curUser.usercode;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;
    for(id cc in [searchBar.subviews[0] subviews]){
        if([cc isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar insertBGColor:SYSBACKGROUNDCOLOR_BLUE];
    [self.myDisplayController setActive:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar insertBGColor:SYSBACKGROUNDCOLOR_BLUE];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _curUsers.queryText = searchBar.text;
    @weakify(self);
    [[NetAPIManager shareManager] request_searchUserByKeywordWithParams:_curUsers andBlock:^(id data, NSError *error) {
        if (data) {
            @strongify(self);
            self.curUsers.list = [NSObject arrayFromJSON:data[@"list"] ofObjects:@"User"];
            self.curUsers.count = [data[@"count"] integerValue];
            [self.myDisplayController.searchResultsTableView reloadData];
        }
    }];
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar insertBGColor:SYSBACKGROUNDCOLOR_DEFAULT];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar insertBGColor:SYSBACKGROUNDCOLOR_DEFAULT];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}


#pragma mark - Action
- (void)addClicked:(id)sender {
    NSLog(@"添加");
}

- (void)clearClicked:(id)sender {
    NSLog(@"清除");
}

- (void)handleActionWithUser:(User *)curUser {
    ApplicationAuthViewController *vc = [[ApplicationAuthViewController alloc] init];
    @weakify(self);
    vc.addedFriendBlock = ^(NSString *confirmMemo) {
        @strongify(self);
       [self addFriend:curUser WithMemo:confirmMemo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addFriend:(User *)curUser WithMemo:(NSString *)memo {
    @weakify(self);
    [[NetAPIManager shareManager] request_add_contactWithParams:curUser withMemo:memo andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            [self.navigationController popViewControllerAnimated:YES];
            [self showHudTipStr:@"添加成功"];
        }
    }];
}
@end
