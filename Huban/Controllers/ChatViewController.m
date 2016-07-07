//
//  ChatViewController.m
//  Huban
//
//  Created by sean on 15/11/20.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatSettingViewController.h"

@interface ChatViewController ()
@property (strong, nonatomic) Contact *curContact;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置Title
    @weakify(self);
    [RACObserve(self, curContact) subscribeNext:^(Contact *contact) {
        @strongify(self);
        if (self.curContact.valid.boolValue) {
            self.tableView.tableHeaderView = nil;
        } else {
            self.tableView.tableHeaderView = [self customerHeaderView];
        }
        self.title = [contact.contactmemo isEmpty]?contact.contactname:contact.contactmemo;
    }];
    // Do any additional setup after loading the view.
    [self setUpBarButtonItem];
    //通过会话管理者获取已收发消息
    [self tableViewDidTriggerHeaderRefresh];
    //更新用户信息
    [self refreshData];
}

- (void)refreshData {
    @weakify(self);
    [[NetAPIManager shareManager] request_get_contactWithParams:self.contactCode andBlock:^(id data, NSError *error) {
        @strongify(self);
        if (data) {
            self.curContact = [NSObject objectOfClass:@"Contact" fromJSON:data];
        }
    }];
}

- (UIView *)customerHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20.f)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.frame];
    label.textColor = [[UIColor blueColor] colorWithAlphaComponent:.5f];
    label.text = @"临时会话";
    label.font = [UIFont systemFontOfSize:12.f];
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    
    return headerView;
}

- (void)setUpBarButtonItem {
    UIBarButtonItem *rightSettingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chatSetting"] style:UIBarButtonItemStylePlain target:self action:@selector(chatSettingClicked)];
    self.navigationItem.rightBarButtonItem = rightSettingItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter deleteMessages:NO append2Chat:YES];
        }

    }
}

#pragma mark - Action
- (void)chatSettingClicked {
    ChatSettingViewController *vc = [[ChatSettingViewController alloc] init];
    vc.curConact = _curContact;
    @weakify(self);
    vc.popToChatVCBlock = ^ {
        @strongify(self);
        [self.navigationController popToViewController:self animated:YES];
    };
    vc.clearRecordBlock = ^ {
        @strongify(self);
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
@end
