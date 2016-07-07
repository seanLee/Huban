//
//  TranspondViewController.m
//  Huban
//
//  Created by sean on 15/12/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "TranspondViewController.h"
#import "TranspondCell.h"

@interface TranspondViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
@property (strong, nonatomic) UIBarButtonItem *sendItem;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UISearchDisplayController *myDisplayController;
@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) Contacts *curContacts;
@property (strong, nonatomic) NSArray *searchDataItem;
@property (strong, nonatomic) NSMutableArray *indexTitleArray;
@property (strong, nonatomic) NSMutableArray *selectedItems;
@end

@implementation TranspondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"选择联系人";
    
    //back
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"backButtonBackImage"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5.f, 0, 0)];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -5.f, 0, 0)];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    //send
    _sendButton = [[UIButton alloc] init];
    [_sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    _sendItem = [[UIBarButtonItem alloc] initWithCustomView:_sendButton];
    self.navigationItem.rightBarButtonItem = _sendItem;
    
    //check
    [self checkSendText];
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        [tableview registerClass:[TranspondCell class] forCellReuseIdentifier:kCellIdentifier_TranspondCell];
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.sectionIndexColor = SYSBACKGROUNDCOLOR_BLUE;
        tableview.sectionIndexBackgroundColor = [UIColor clearColor];
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        [searchVC.searchResultsTableView registerClass:[TranspondCell class] forCellReuseIdentifier:kCellIdentifier_TranspondCell];
        searchVC.delegate = self;
        searchVC.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        searchVC.searchResultsDataSource = self;
        searchVC.searchResultsDelegate = self;
        searchVC.displaysSearchBarInNavigationBar = NO;
        searchVC;
    });
    
    _curContacts = [[Contacts alloc] init];
    _indexTitleArray = [[NSMutableArray alloc] init];
    _selectedItems = [[NSMutableArray alloc] init];
    
    //先刷新本地数据
    [self refreshContactList];
    
    //监控用户选择的数组
    [self addObserver:self forKeyPath:@"selectedItems" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
}

- (void)refreshContactList {
    Contacts *curContacts = [[Contacts alloc] init];
    //获取本地的所有好友记录
    NSArray *originArray = [[DataBaseManager shareInstance] queryContacts];
    
    //userDefault
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [[NetAPIManager shareManager] request_get_contactListVersionWithBlock:^(id versionData, NSError *error) {
        if (versionData) {
            NSNumber *curVersion = versionData[@"value"];
            NSNumber *oldVersion = [userDefaults objectForKey:kContactListVersion];
            if (oldVersion < curVersion) { //从服务器获取最新好友列表
                [[NetAPIManager shareManager] request_get_contactListWithParams:curContacts andBlock:^(id data, NSError *error) {
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
            } else {
                [self.curContacts configArray:originArray]; //获取本地数据
                [self resoltContacts];
            }
        }
    }];
    
}

- (void)resoltContacts {
    [_indexTitleArray removeAllObjects];
    [_indexTitleArray addObjectsFromArray:_curContacts.indexLetterArray];
    [self.myTableView reloadData];
}

- (void)reloadDataSource:(NSArray *)dataItems {
    [self.curContacts configArray:dataItems];
    [self.curContacts resortIndexArray];
    [self resoltContacts];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"selectedItems"];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return 1;
    }
    return _indexTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return _searchDataItem.count;
    }
    return [_curContacts contactInLetter:_indexTitleArray[section]].count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return nil;
    }
    return _indexTitleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == _myDisplayController.searchResultsTableView) {
        return @"";
    }
    return _indexTitleArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TranspondCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TranspondCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TranspondCell forIndexPath:indexPath];
    Contact *curContact;
    if (tableView == _myDisplayController.searchResultsTableView) {
        curContact = _searchDataItem[indexPath.row];
    } else {
        curContact = [_curContacts contactInLetter:_indexTitleArray[indexPath.section]][indexPath.row];
    }
    cell.checked = [self.selectedItems containsObject:curContact];
    cell.curContact = curContact;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Contact *curContact;
    //get the item
    if (tableView == _myDisplayController.searchResultsTableView) {
         curContact = _searchDataItem[indexPath.row];
    } else {
        curContact = [_curContacts contactInLetter:_indexTitleArray[indexPath.section]][indexPath.row];
    }
    //modefy the dataSource
    if ([[self mutableArrayValueForKey:@"selectedItems"] containsObject:curContact]) {
        [[self mutableArrayValueForKey:@"selectedItems"]  removeObject:curContact];
    } else {
        [[self mutableArrayValueForKey:@"selectedItems"]  addObject:curContact];
    }
    //reload
    [self.myDisplayController.searchResultsTableView reloadData];
    [self.myTableView reloadData];
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
    NSString *keyStr = searchBar.text;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"contactmobile contains %@ or contactname contains %@",keyStr,keyStr];
    _searchDataItem = [self.curContacts.allContacts filteredArrayUsingPredicate:searchPredicate];
    [self.myDisplayController.searchResultsTableView reloadData];
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

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selectedItems"]) {
        [self checkSendText];
    }
}

- (void)checkSendText {
     NSInteger selectedCount = self.selectedItems.count;
    if (selectedCount == 0) {
        _sendButton.enabled = NO;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    } else {
        _sendButton.enabled = YES;
        [_sendButton setTitle:[NSString stringWithFormat:@"发送(%@)",@(selectedCount)] forState:UIControlStateNormal];
    }
    [_sendButton sizeToFit];
}

#pragma mark - Action
- (void)sendAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedItemsBlock) {
            self.selectedItemsBlock([self.selectedItems copy]);
        }
    }];
}

- (void)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
