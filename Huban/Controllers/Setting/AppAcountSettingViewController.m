//
//  AppAcountSettingViewController.m
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "AppAcountSettingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TextFieldCell.h"

@interface AppAcountSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) NSString *currentStr;
@end

@implementation AppAcountSettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置呼伴账号";
    
    //tableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:kCellIdentifier_TextFieldCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    //footer
    _myTableView.tableFooterView = [self customerFooterView];
    //right bar item
    UIBarButtonItem *saveItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    RAC(saveItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, currentStr)]
                                               reduce:^id(NSString *appAccount){
                                                   return @(appAccount && appAccount.length > 0);
                                               }];
}

- (UIView *)customerFooterView {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    footer.backgroundColor = [UIColor clearColor];
    
    CGFloat labelHeight = 20.f;
    
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth, kScreen_Width - kPaddingLeftWidth, labelHeight)];
    labelOne.textColor = [UIColor colorWithHexString:@"0x999999"];
    labelOne.font = [UIFont systemFontOfSize:12.f];
    labelOne.text = @"呼伴账号是唯一凭证,只能设置一次.";
    [footer addSubview:labelOne];
    
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kPaddingLeftWidth + labelHeight, kScreen_Width - kPaddingLeftWidth, labelHeight)];
    labelTwo.textColor = [UIColor colorWithHexString:@"0x999999"];
    labelTwo.font = [UIFont systemFontOfSize:12.f];
    labelTwo.text = @"呼伴账号仅支持6-20个字母或数字.";
    [footer addSubview:labelTwo];
    
    return footer;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TextFieldCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(24) andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TextFieldCell forIndexPath:indexPath];
    [cell setPlacerStr:@"请输入呼伴账号"];
    __weak typeof(self) weakSelf = self;
    cell.textChangedBlock = ^(NSString *inputStr) {
        weakSelf.currentStr = inputStr;
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Action
- (void)save {
    __weak typeof(self) weakSelf = self;
    if (self.currentStr.length < 6 || self.currentStr.length > 20 || [self.currentStr containChinese]) {
        [self showHudTipStr:@"请输入6-20个字母或数字"];
    } else {
        User *loginUser = [Login curLoginUser];
        loginUser.useruid = _currentStr;
        [[NetAPIManager shareManager] request_updateUserInfo:loginUser andBlock:^(id data, NSError *error) {
            if (data) {
                if ([data[@"state"] integerValue] == 1) {
                    if (weakSelf.refreshBlock) {
                        weakSelf.refreshBlock();
                    }
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    [self showHudTipStr:@"绑定账号成功"];
                }
            }
        }];
    }
}
@end
