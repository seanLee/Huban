//
//  ChatSettingViewController.m
//  Huban
//
//  Created by sean on 15/8/8.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "ToUserCell.h"
#import "TitleAndSwitchCell.h"
#import "TitleDisclosureCell.h"
#import "UserInfoViewController.h"

@interface ChatSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *titleArray;

@property (strong, nonatomic) EMConversation *conversatoin;
@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"聊天设置";
    
    //tableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        [tableView registerClass:[ToUserCell class] forCellReuseIdentifier:kCellIdentifier_ToUserCell];
        [tableView registerClass:[TitleAndSwitchCell class] forCellReuseIdentifier:kCellIdentifier_TitleAndSwitchCell];
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _titleArray = [NSMutableArray new];
    [_titleArray addObject:@[@"置顶聊天",@"消息免打扰",@"屏蔽此人消息",@"查找聊天记录",@"清空聊天记录"]];
    if (_curConact.valid.boolValue) {
        [_titleArray addObject:@[@"举报",@"删除",@"加入黑名单"]];
    } else {
        [_titleArray addObject:@[@"举报",@"加入黑名单"]];
        _myTableView.tableFooterView = [self customerFooter];
    }
    
     _conversatoin = [[EaseMob sharedInstance].chatManager conversationForChatter:_curConact.contactcode conversationType:eConversationTypeChat];
}

- (UIView *)customerFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 100.f)];
    //login button
    UIButton *addButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"加为好友" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(addClicked:)];
    [footerView addSubview:addButton];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(35);
        make.centerX.equalTo(footerView);
        make.height.mas_equalTo(35);
        make.width.equalTo(footerView).offset(-2*23.f);
    }];
    
    return footerView;
}

- (NSArray *)titleForSection:(NSInteger)section {
    return _titleArray[section];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self titleForSection:0].count;
    }
    return [self titleForSection:1].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [ToUserCell cellHeight];
    } else if (indexPath.section == 1 && indexPath.row < 3) {
        return [TitleAndSwitchCell cellHeight];
    }
    return [TitleDisclosureCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 1?0:20.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ToUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ToUserCell forIndexPath:indexPath];
        cell.contact = _curConact;
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    } else if (indexPath.section == 1 && indexPath.row < 3) {
        TitleAndSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleAndSwitchCell forIndexPath:indexPath];
        [cell setTitleStr:[self titleForSection:0][indexPath.row]];
        switch (indexPath.row) {
            case 0: {
                NSDictionary *ext = self.conversatoin.ext;
                NSNumber *isSetTop = ext[@"top"];
                cell.switchSelected = isSetTop.boolValue;
                @weakify(self);
                cell.haveSwitchSettingBlock = ^(BOOL switched) {
                   @strongify(self);
                    if (switched) {
                        self.conversatoin.ext = @{@"top":@1,@"topDate":@([[NSDate date] timeIntervalSince1970])};
                    } else {
                        self.conversatoin.ext = nil;
                    }
                };
            }
                break;
            case 1: {
                cell.switchSelected = !self.conversatoin.enableUnreadMessagesCountEvent;
                @weakify(self);
                cell.haveSwitchSettingBlock = ^(BOOL switched) {
                    @strongify(self);
                    self.conversatoin.enableUnreadMessagesCountEvent = !switched;
                };
            }
                break;
            case 2: {
                cell.switchSelected = self.curConact.spamshield.boolValue;
                @weakify(self);
                cell.haveSwitchSettingBlock = ^ (BOOL switched) {
                    @strongify(self);
                    self.curConact.spamshield = @(switched);
                    if (switched) {
                        [[EaseMob sharedInstance].chatManager blockBuddy:self.curConact.contactcode relationship:eRelationshipFrom];
                    } else {
                        [[EaseMob sharedInstance].chatManager unblockBuddy:self.curConact.contactcode];
                    }
                    [self refreshSpamshield];
                };
            }
                break;
                
            default:
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
    if (indexPath.section == 1 && indexPath.row >= 3) {
        [cell setTitleStr:[self titleForSection:0][indexPath.row]];
    } else if (indexPath.section == 2) {
        [cell setTitleStr:[self titleForSection:1][indexPath.row]];
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2)) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
            @weakify(self);
            vc.popToChatVCBlock = ^ {
                @strongify(self);
                if (self.popToChatVCBlock) {
                    self.popToChatVCBlock();
                }
            };
            vc.userCode = self.curConact.contactcode;
            vc.fromChatVC = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1: {
            switch (indexPath.row) {
                case 3: {
                
                }
                    break;
                case 4: {
                    @weakify(self);
                    [[UIActionSheet bk_actionSheetCustomWithTitle:@"是否删除与该用户的聊天记录?" buttonTitles:@[@"删除"] destructiveTitle:nil cancelTitle:@"取消" andDidDismissBlock:^(UIActionSheet *sheet, NSInteger index) {
                        @strongify(self);
                        if (index == 0) {
                            [self.conversatoin removeAllMessages];
                            [self.navigationController popViewControllerAnimated:YES];
                            if (self.clearRecordBlock) {
                                self.clearRecordBlock();
                            }
                        }
                    }] showInView:self.view];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    NSLog(@"举报");
                }
                    break;
                case 1: {
                    if (_curConact.valid.boolValue) {
                        NSLog(@"删除");
                    } else {
                        NSLog(@"黑名单");
                    }
                }
                    break;
                case 2: {
                    NSLog(@"黑名单");
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Action
- (void)addClicked:(id)sender {
    NSLog(@"加为好友");
}

- (void)refreshSpamshield {
    @weakify(self);
    [[NetAPIManager shareManager] request_contact_changeSpamshieldWithParams:self.curConact andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            //更新本地数据
            [[DataBaseManager shareInstance] updateContact:self.curConact];
        }
    }];
}
@end
