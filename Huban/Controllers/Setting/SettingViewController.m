//
//  SettingViewController.m
//  Huban
//
//  Created by sean on 15/7/30.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "SettingViewController.h"
#import "TitleDisclosureCell.h"
#import "SettingInfoCell.h"
#import "MessageSettingViewController.h"
#import "PrivacyViewController.h"
#import "MeSettingViewController.h"
#import "AboutViewController.h"
#import "FeedBakcViewController.h"
#import "AccountSettingViewController.h"
#import "Message_RootViewController.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIButton *logoutButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableArray *titleArray;

@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [tableView registerClass:[SettingInfoCell class] forCellReuseIdentifier:kCellIdentifier_SettingInfoCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableFooterView = [self customerFooter];
    [self setupTitles];
}

- (UIView *)customerFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 100.f)];
    //login button
    _logoutButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"退出账号" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(logout)];
    [footerView addSubview:_logoutButton];
    
    [_logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(35);
        make.centerX.equalTo(footerView);
        make.height.mas_equalTo(35);
        make.width.equalTo(footerView).offset(-2*23.f);
    }];

    return footerView;
}

- (void)setupTitles {
    _titleArray = [NSMutableArray array];
    [_titleArray addObject:@[@""]];
    [_titleArray addObject:@[@"账号与安全",@"消息管理",@"隐私管理",@"清空所有聊天记录"]];
    [_titleArray addObject:@[@"意见反馈",@"关于呼伴"]];
}

- (NSInteger)valueListForSection:(NSInteger)section {
    if (section < _titleArray.count) {
        NSArray *curArray = [_titleArray objectAtIndex:section];
        return curArray.count;
    }
    return 0;
}

- (NSString *)titleStrForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < _titleArray.count) {
        NSArray *curArray = [_titleArray objectAtIndex:indexPath.section];
        return [curArray objectAtIndex:indexPath.row];
    }
    return @"";
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self valueListForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        SettingInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SettingInfoCell forIndexPath:indexPath];
        cell.curUser = [Login curLoginUser];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
    if (indexPath.section == 1 && indexPath.row == 3) {
        cell.showIndicator = NO;
    } else {
        cell.showIndicator = YES;
    }
    [cell setTitleStr:[self titleStrForIndexPath:indexPath]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [SettingInfoCell cellHeight];
    }
    return [TitleDisclosureCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        MeSettingViewController *vc = [[MeSettingViewController alloc] init];
        vc.refreshBlock = ^ {
            [weakSelf.myTableView reloadData];
            if (weakSelf.refreshBlock) {
                weakSelf.refreshBlock();
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                AccountSettingViewController *vc = [[AccountSettingViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1: {
                MessageSettingViewController *vc = [[MessageSettingViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2: {
                PrivacyViewController *vc = [[PrivacyViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 3:
                @weakify(self);
                [[UIActionSheet bk_actionSheetCustomWithTitle:@"将删除所有的聊天记录以及通知内容" buttonTitles:nil destructiveTitle:@"清空聊天记录" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                    @strongify(self);
                    if (index == 0) {
                        [self clearAllRecord];
                    }
                }] showInView:self.view];
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: {
                FeedBakcViewController *vc = [[FeedBakcViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1: {
                AboutViewController *vc = [[AboutViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil];
}

#pragma mark - Private Method
- (void)clearAllRecord {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.labelText = @"正在清理数据";
        _hud.delegate = self;
        [_hud show:YES];
        [self.view addSubview:_hud];
    }
    //删除环信的所有聊天记录
    if ([[EaseMob sharedInstance].chatManager removeAllConversationsWithDeleteMessages:YES append2Chat:NO]) {
        //如果聊天记录删除成功,删除推送设置
        if ([[DataBaseManager shareInstance] removeAllNoficatonInfo]) {
            [_hud hide:YES];
            Message_RootViewController *vc = (Message_RootViewController *)[UIViewController message_rootVC];
            [vc tableViewDidTriggerHeaderRefresh];
        }
    }
}

#pragma mark - Action
- (void)logout {
    __weak typeof(self) weakSelf = self;
    [[UIActionSheet bk_actionSheetCustomWithTitle:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号." buttonTitles:nil destructiveTitle:@"退出登录" cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
        if (index == 0) {
            [weakSelf.view endEditing:YES];
            if (!weakSelf.activityIndicator) {
                weakSelf.activityIndicator = [[UIActivityIndicatorView alloc]
                                      initWithActivityIndicatorStyle:
                                      UIActivityIndicatorViewStyleGray];
                CGSize captchaViewSize = weakSelf.logoutButton.bounds.size;
                weakSelf.activityIndicator.hidesWhenStopped = YES;
                [weakSelf.activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
                [weakSelf.logoutButton addSubview:weakSelf.activityIndicator];
            }
            
            [weakSelf.activityIndicator startAnimating];
            
            [[NetAPIManager shareManager] request_logoutWithBlock:^(id data, NSError *error) {
                [weakSelf.activityIndicator stopAnimating];
                if (data) {//退出界面
                    if ([data[@"state"] integerValue] == 1) {
                        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
                            [weakSelf loginOutToLoginVC];
                        } onQueue:dispatch_get_main_queue()];
                    }
                }
            }];
        }
    }] showInView:self.view];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    hud = nil;
    [self showHudTipStr:@"理清完成"];
}
@end
