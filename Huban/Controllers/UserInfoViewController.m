//
//  UserInfoViewController.m
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "UserInfoViewController.h"
#import "TitleValueCell.h"
#import "UserAlbumCell.h"
#import "DropDownMenu.h"
#import "SettingTextViewController.h"
#import "ODRefreshControl.h"
#import "ChatViewController.h"
#import "AlbumViewController.h"
#import "ApplicationAuthViewController.h"

@interface UserInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) Contact *curRelation;
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) BOOL isMe;

@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *refreshControl;
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"详细资料";
    
    //tableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UserInfoCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoCell];
        [tableView registerClass:[TitleValueCell class] forCellReuseIdentifier:kCellIdentifier_TitleValue];
        [tableView registerClass:[UserAlbumCell class] forCellReuseIdentifier:kCellIdentifier_UserAlbumCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self refreshData];
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    //action view
    _myTableView.tableFooterView = [self customerFooter];
    
    @weakify(self);
    [RACObserve(self, curRelation) subscribeNext:^(Contact *relation) {
        @strongify(self);
        if (relation) {
            [self refreshUserInfo];
        }
    }];
    [RACObserve(self, curUser) subscribeNext:^(User *user) {
        @strongify(self);
        if (user) {
            //刷新列表
            self.myTableView.tableFooterView = [self customerFooter];
            [self.myTableView reloadData];
        }
    }];
}

- (void)refreshUserInfo {
    if (!_userCode || [_userCode isEmpty]) {
        _userCode = self.curUser.usercode;
    }
    if ([_userCode isEqualToString:[Login curLoginUser].usercode]) { //如果显示当前登录用户的信息
        self.curUser = [Login curLoginUser];
        [self.refreshControl endRefreshing];
    } else {
        //先加载本地信息
        User *originUser = [[DataBaseManager shareInstance] userByUserCode:self.userCode];
        self.curUser = originUser;
        @weakify(self);
        [[NetAPIManager shareManager] request_get_userWithUsercode:self.userCode andBlock:^(id data, NSError *error) {
            [self.refreshControl endRefreshing];
            @strongify(self);
            if (data) {
                if (self.curRelation.valid.boolValue) { //仅仅刷新好友的数据
                    if (originUser) { //如果本地存在数据,更新数据
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [[DataBaseManager shareInstance] deleteUser:originUser];
                        });
                    }
                    [self loadUserinfoForData:data];
                } else { //如果不是好友,则只需要缓存一次数据
                    if (!originUser) { //或者如果本地不存在对应关系数据,则保存数据
                        [self loadUserinfoForData:data];
                    }
                }

            }
        }];
    }
}

- (void)refreshData {
    if ([self.userCode isEqualToString:[Login curLoginUser].usercode]) { //如果显示的是登录用户
        _isMe = YES;
        [self refreshUserInfo];
    } else {
        //查询本地用户关系
        Contact *localContact = [[DataBaseManager shareInstance] relationForUser:self.userCode];
        self.curRelation = localContact;
        @weakify(self);
        //从服务器查询数据库
        [[NetAPIManager shareManager] request_get_contactWithParams:self.userCode andBlock:^(id data, NSError *error) {
            @strongify(self);
            if (data) { //如果查询到contact
                if (localContact) { //如果本地存在数据,更新数据
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[DataBaseManager shareInstance] deleteContact:localContact];
                    });
                }
                [self loadRelationForData:data];
            }
        }];
    }
}

- (void)loadRelationForData:(id)data {
    self.curRelation = [NSObject objectOfClass:@"Contact" fromJSON:data];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DataBaseManager shareInstance] saveContact:self.curRelation];
    });
}

- (void)loadUserinfoForData:(id)data {
    self.curUser = [NSObject objectOfClass:@"User" fromJSON:data];
    //刷新数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DataBaseManager shareInstance] saveUser:self.curUser];
    });
}

- (UIView *)customerFooter {
    self.navigationItem.rightBarButtonItem = nil;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 150.f)];
    if (self.isMe) { //如果显示的是登录用户
        UIButton *sendMessageButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"发消息" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(sendMessage:)];
        [footer addSubview:sendMessageButton];
        [sendMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footer).offset(35);
            make.height.mas_equalTo(35);
            make.left.equalTo(footer).offset(kPaddingLeftWidth);
            make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        }];
    } else if (_curRelation.blocked.boolValue || self.fromSearchVC) { //如果被拉黑或者从在搜索界面显示好友信息
        //对方在黑名单中
        UIButton *addedButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"添加好友" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(addClicked:)];
        [footer addSubview:addedButton];
        [addedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footer).offset(35);
            make.height.mas_equalTo(35);
            make.left.equalTo(footer).offset(kPaddingLeftWidth);
            make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        }];
    } else if (_curRelation.valid.boolValue) { //如果是好友
        //显示操作DropMenu
        UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(moreClicked)];
        self.navigationItem.rightBarButtonItem = moreItem;
        //login button
        UIButton *sendMessageButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"发消息" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(sendMessage:)];
        [footer addSubview:sendMessageButton];
        [sendMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footer).offset(35);
            make.height.mas_equalTo(35);
            make.left.equalTo(footer).offset(kPaddingLeftWidth);
            make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        }];
    } else {
        //login button
        UIButton *tempMessageButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"临时消息" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(sendMessage:)];
        [footer addSubview:tempMessageButton];
        [tempMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(footer).offset(35);
            make.height.mas_equalTo(35);
            make.left.equalTo(footer).offset(kPaddingLeftWidth);
            make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        }];
        
        UIButton *addButton = [UIButton buttonWithStyle:StrapDefaultStyle andTitle:@"添加好友" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(addClicked:)];
        [footer addSubview:addButton];
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(tempMessageButton.mas_bottom).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(35);
            make.left.equalTo(footer).offset(kPaddingLeftWidth);
            make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        }];
    }
    return footer;
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0?1:3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [UserInfoCell cellHeight];
    } else if (indexPath.section == 1 && indexPath.row == 2){
        cellHeight = [UserAlbumCell cellHeight];
    } else {
        cellHeight = [TitleValueCell cellHeight];
    }
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0?10.f:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoCell forIndexPath:indexPath];
        cell.curUser = _curUser;
        cell.curContact = _curRelation;
        cell.infoType = _infoType;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    } else if (indexPath.section == 1 && indexPath.row == 2){
        UserAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserAlbumCell forIndexPath:indexPath];
        [cell setTitleStr:@"个人相册"];
        cell.dataItems = [self.curUser.userTrends componentsSeparatedByString:@","];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
        return cell;
    } else {
        TitleValueCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValue forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0: {
                [cell setTitleStr:@"地区" valueStr:_curUser.cityname];
            }
                break;
            default:
                [cell setTitleStr:@"个性签名" valueStr:_curUser.usersign];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 2) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AlbumViewController *vc = [[AlbumViewController alloc] init];
    vc.relation = self.curRelation;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (void)moreClicked {
    DropDownMenu *dropDownMenu = [[DropDownMenu alloc] initWithFrame:kKeyWindow.frame];
    dropDownMenu.dataItem = [NSArray arrayWithObjects:@"设置备注名",@"举报",@"删除",_curRelation.blocked.boolValue?@"移除黑名单":@"加入黑名单", nil];
    dropDownMenu.cancleBlock = ^(DropDownMenu *menu) {
        [menu removeFromSuperview];
        menu = nil;
    };
    __weak typeof(self) weakSelf = self;
    __weak typeof(DropDownMenu) *weakMenu = dropDownMenu;
    dropDownMenu.clickedIndexBlock = ^(NSInteger selectIndex){
        switch (selectIndex) {
            case 0: {
                [weakMenu hide];
                SettingTextViewController *vc = [[SettingTextViewController alloc] init];
                vc.canSubmibNil = YES;
                vc.doneBlock = ^ (NSString *textValue) {
                    weakSelf.curRelation.contactmemo = textValue;
                    @weakify(self);
                    [[NetAPIManager shareManager] request_contact_changeMemoWithParams:_curRelation andBlock:^(id data, NSError *error) {
                        @strongify(self);
                        if (data) {
                            if ([[DataBaseManager shareInstance] updateContact:self.curRelation]) {
                                [self.myTableView reloadData];
                            }
                        }
                    }];
                };
                vc.title = @"设置备注名";
                vc.textValue = _curRelation.contactmemo;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
                
                break;
            case 2: {
                [[UIAlertView bk_showAlertViewWithTitle:nil message:@"同时将我从对方的列表中删除,并清空所有聊天记录" cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        @weakify(self);
                        [[NetAPIManager shareManager] request_delete_contactWithParams:_curRelation andBlock:^(id data, NSError *error) {
                            @strongify(self);
                            if (data) {
                                if ([[DataBaseManager shareInstance] deleteContact:_curRelation]) { //删除好友之后 删除本地纪录
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }
                        }];
                    }
                }] show];
                [weakMenu hide];
            }
                break;
            case 3: {
                if (_curRelation.blocked.boolValue) {
                    [UIAlertView bk_showAlertViewWithTitle:nil message:@"是否将对方移除黑名单" cancelButtonTitle:@"取消" otherButtonTitles:@[@"移除黑名单"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            _curRelation.blocked = @0;
                            @weakify(self);
                            [[NetAPIManager shareManager] request_contact_changeBlockWithParams:_curRelation andBlock:^(id data, NSError *error) {
                                @strongify(self);
                                if (data) {
                                    if ([[DataBaseManager shareInstance] updateContact:self.curRelation]) { //更新本地信息
                                        [self.navigationController popViewControllerAnimated:YES];
                                        [self showHudTipStr:@"操作成功"];
                                    }
                                }
                            }];
                        }
                    }];
                } else {
                    [UIAlertView bk_showAlertViewWithTitle:nil message:@"加入黑名单,您将不再收到对方的任何消息" cancelButtonTitle:@"取消" otherButtonTitles:@[@"加入黑名单"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            _curRelation.blocked = @1;
                            @weakify(self);
                            [[NetAPIManager shareManager] request_contact_changeBlockWithParams:_curRelation andBlock:^(id data, NSError *error) {
                                @strongify(self);
                                if (data) {
                                    if ([[DataBaseManager shareInstance] updateContact:self.curRelation]) { //更新本地信息
                                        [self.navigationController popViewControllerAnimated:YES];
                                        [self showHudTipStr:@"操作成功"];
                                    }
                                }
                            }];
                        }
                    }];
                }
                [weakMenu hide];
            }
                break;
            default:
                break;
        }
    };
    [dropDownMenu showInView:kKeyWindow];
}

- (void)sendMessage:(id)sender {
    if (_fromChatVC) { //如果是从聊天过来的
        if (_popToChatVCBlock) {
            _popToChatVCBlock();
        }
    } else {
        ChatViewController *vc = [[ChatViewController alloc] initWithConversationChatter:_curRelation.contactcode conversationType:eConversationTypeChat];
        vc.contactCode = _curRelation.contactcode;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)addClicked:(id)sender {
    if (_curRelation.blocked.boolValue) {
        [UIAlertView bk_showAlertViewWithTitle:nil message:@"此联系人已在您的黑名单,添加好友将从黑名单中移除,确定要添加好友吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self goToApplicationAuth];
            }
        }];
    } else if (_curRelation.spamshield.boolValue) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您已在对方的黑名单中,无法添加好友";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
    } else {
        [self goToApplicationAuth];
    }
}

- (void)goToApplicationAuth {
    ApplicationAuthViewController *vc = [[ApplicationAuthViewController alloc] init];
    @weakify(self);
    vc.addedFriendBlock = ^(NSString *confirmMemo) {
        @strongify(self);
        [self addFriendWithMemo:confirmMemo];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addFriendWithMemo:(NSString *)memo {
    @weakify(self);
    [[NetAPIManager shareManager] request_add_contactWithParams:self.curUser withMemo:memo andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            self.curRelation.valid = @1;
            self.myTableView.tableFooterView = [self customerFooter];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self showHudTipStr:@"添加成功"];
            });
        }
    }];
}

#pragma mark - Getter
- (Contact *)curRelation {
    if (!_curRelation) {
        _curRelation = [[Contact alloc] init];
        _curRelation.contactcode = self.userCode;
    }
    return _curRelation;
}
@end
