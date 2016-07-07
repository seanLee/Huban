//
//  PrivacyViewController.m
//  Huban
//
//  Created by sean on 15/8/1.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "PrivacyViewController.h"
#import "TitleAndSwitchCell.h"
#import "TitleDisclosureCell.h"
#import "BlackListViewController.h"

@interface PrivacyViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSArray *titleArr;
@property (strong, nonatomic) User *loginUser;
@end

@implementation PrivacyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"隐私管理";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleAndSwitchCell class] forCellReuseIdentifier:kCellIdentifier_TitleAndSwitchCell];
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _loginUser = [Login curLoginUser];
    _titleArr = @[@"通讯录黑名单",@"添加时需要验证",@"屏蔽所有临时消息",@"允许陌生人查看十张照片"];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
        cell.showIndicator = YES;
        [cell setTitleStr:_titleArr[indexPath.row]];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    } else {
        __weak typeof(self) weakSelf = self;
        TitleAndSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleAndSwitchCell forIndexPath:indexPath];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        [cell setTitleStr:_titleArr[indexPath.row]];
        switch (indexPath.row) {
            case 1: {
                cell.switchSelected = _loginUser.needconfirm.boolValue;
                cell.haveSwitchSettingBlock = ^ (BOOL selected) {
                    weakSelf.loginUser.needconfirm = @(selected);
                    [[NetAPIManager shareManager] request_updateNeedConfirmWithParams:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                        if (data) {
                            //保存修改信息
                            [Login doLogin:[weakSelf.loginUser objectDictionary] completion:nil];
                        }
                    }];
                };
            }
                break;
            case 2: {
                cell.switchSelected = _loginUser.spamshield.boolValue;
                cell.haveSwitchSettingBlock = ^ (BOOL selected) {
                    weakSelf.loginUser.spamshield = @(selected);
                    [[NetAPIManager shareManager] request_updateSpamshieldWithParams:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                        if (data) {
                            //保存修改信息
                            [Login doLogin:[weakSelf.loginUser objectDictionary] completion:nil];
                        }
                    }];
                };
            }
                break;
            default: {
                cell.switchSelected = (_loginUser.viewpermit.intValue == 0);
                cell.haveSwitchSettingBlock = ^ (BOOL selected) {
                    weakSelf.loginUser.viewpermit = selected?@0:@1;
                    [[NetAPIManager shareManager] request_updateViewpermitWithParams:weakSelf.loginUser andBlock:^(id data, NSError *error) {
                        if (data) {
                            //保存修改信息
                            [Login doLogin:[weakSelf.loginUser objectDictionary] completion:nil];
                        }
                    }];
                };
            }
                break;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BlackListViewController *vc = [[BlackListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return YES;
    }
    return NO;
}
@end
