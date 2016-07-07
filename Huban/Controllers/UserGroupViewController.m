//
//  UserGroupViewController.m
//  Huban
//
//  Created by sean on 15/8/17.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UserGroupViewController.h"
#import "UserGroupCell.h"

@interface UserGroupViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableDictionary *dataItem;
@property (strong, nonatomic) NSArray *keyArray;

@property (strong, nonatomic) NSMutableIndexSet *dropDownSet;
@end

@implementation UserGroupViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"好友分组";
    
    //right item
    UIBarButtonItem *newGroupItem = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStylePlain target:self action:@selector(newGroupClick)];
    self.navigationItem.rightBarButtonItem = newGroupItem;
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserGroupCell class] forCellReuseIdentifier:kCellIdentifier_UserGroupCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _myTableView.tableHeaderView = [self customerHeader];
    
    _dataItem = [NSMutableDictionary new];
    [_dataItem setObject:@[@"测试",@"测试",@"测试"] forKey:@"好友"];
    [_dataItem setObject:@[@"测试",@"测试",@"测试",@"测试",@"测试"] forKey:@"同学"];
    [_dataItem setObject:@[@"测试",@"测试"] forKey:@"同事"];
    //get the key title of the section
    _keyArray = [_dataItem allKeys];
    
    _dropDownSet = [NSMutableIndexSet indexSet];
}

- (UIView *)customerHeader {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 10.f)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (NSArray *)itemsForSection:(NSInteger)section {
    return _dataItem[_keyArray[section]];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keyArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hasDropDown = [_dropDownSet containsIndex:indexPath.section];
    return [UserGroupCell cellHeightWithDataItms:[self itemsForSection:indexPath.section] andDropList:hasDropDown];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    UserGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserGroupCell forIndexPath:indexPath];
    cell.groupTitleTapBlock = ^(BOOL hasDropDown) {
        if (hasDropDown) {
            [weakSelf.dropDownSet addIndex:indexPath.section];
        } else {
            [weakSelf.dropDownSet removeIndex:indexPath.section];
        }
        [weakSelf.myTableView reloadData];
    };
    [cell setGroupTitleStr:_keyArray[indexPath.section]];
    [cell addLineUp:YES andDown:NO];
    return cell;
}

#pragma mark - Action
- (void)newGroupClick {
    NSLog(@"新建");
}
@end
