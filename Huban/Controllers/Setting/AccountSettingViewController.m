//
//  AccountSettingViewController.m
//  Huban
//
//  Created by sean on 15/8/13.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AccountSettingViewController.h"
#import "TitleValueMoreCell.h"
#import "CodeSettingViewController.h"
#import "AppAcountSettingViewController.h"
#import "BoundingPhoneViewController.h"

@interface AccountSettingViewController () <UITableViewDataSource ,UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) User *loginUser;
@end

@implementation AccountSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账号与安全";
    
    _loginUser = [Login curLoginUser];
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self setupTitles];
}

- (void)setupTitles {
    _titleArray = [NSMutableArray new];
    [_titleArray addObject:@"呼伴账号"];
    [_titleArray addObject:@"手机绑定"];
    [_titleArray addObject:@"修改密码"];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TitleValueMoreCell cellHeightWithStr:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
    cell.showIndicator = YES;
    switch (indexPath.row) {
        case 0: {
            if (_loginUser.useruid.length == 0) {
                [cell setTitleStr:_titleArray[indexPath.row] valueStr:@"未设置"];
            } else {
                cell.showIndicator = NO;
                [cell setTitleStr:_titleArray[indexPath.row] valueStr:_loginUser.useruid];
            }
        }
            break;
        case 1:
            [cell setTitleStr:_titleArray[indexPath.row] valueStr:nil];
            break;
        case 2:
            [cell setTitleStr:_titleArray[indexPath.row] valueStr:nil];
            break;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return _loginUser.useruid.length == 0;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0: {
            AppAcountSettingViewController *vc = [[AppAcountSettingViewController alloc] init];
            vc.refreshBlock = ^ {
                [weakSelf.myTableView reloadData];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            BoundingPhoneViewController *vc = [[BoundingPhoneViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2: {
            CodeSettingViewController *vc = [[CodeSettingViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}
@end
