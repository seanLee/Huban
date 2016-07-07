//
//  CodeSettingViewController.m
//  Huban
//
//  Created by sean on 15/8/13.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CodeSettingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "TextFieldCell.h"
#import "CannotLogin.h"

@interface CodeSettingViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) NSString *curLogonPass;
@property (strong, nonatomic) NSArray *placerArr;
@property (strong, nonatomic) CannotLogin *cannotLogin;
@end

@implementation CodeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置密码";
    
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
    
    _placerArr = @[@"当前密码",@"新密码",@"确认新密码"];
    
    //right bar item
    UIBarButtonItem *saveItem = [UIBarButtonItem itemWithBtnTitle:@"保存" target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    //modefy code object
    _cannotLogin = [[CannotLogin alloc] init];
    _cannotLogin.userMobile = [Login curLoginUser].usermobile;
    
    RAC(saveItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, cannotLogin.userPass),
                                                        RACObserve(self, cannotLogin.repeatPass)]
                                               reduce:^id(NSString *code, NSString *repeatCode){
                                                   return @((code && code.length > 0) && (repeatCode && repeatCode.length > 0));
                                               }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _placerArr.count;
}

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
    cell.isSecret = YES;
    [cell setPlacerStr:_placerArr[indexPath.section]];
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        cell.textChangedBlock = ^(NSString *inputStr) {
            weakSelf.cannotLogin.originPass = inputStr;
        };
    } else if (indexPath.section == 1) {
        cell.textChangedBlock = ^(NSString *inputStr) {
            weakSelf.cannotLogin.userPass = inputStr;
        };
    } else if (indexPath.section == 2) {
        cell.textChangedBlock = ^(NSString *inputStr) {
            weakSelf.cannotLogin.repeatPass = inputStr;
        };
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Action
- (void)save {
    if (_cannotLogin.originPass.length == 0 || _cannotLogin.userPass.length < 6 || _cannotLogin.userPass.length > 20) {
        [self showHudTipStr:@"请输入正确格式的密码"];
    } else if (![_cannotLogin.userPass isEqual:_cannotLogin.repeatPass]) {
        [self showHudTipStr:@"请确保两次密码输一致"];
    } else {
        __weak typeof(self) weakSelf = self;
        [[NetAPIManager shareManager] request_reset_passWithParams:_cannotLogin andBlock:^(id data, NSError *error) {
            if (data) {
                if ([data[@"state"] intValue] == 1) {
                    [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    [weakSelf showHudTipStr:@"密码修改成功,下次登录请使用新密码"];
                }
            } 
        }];
    }}
@end
