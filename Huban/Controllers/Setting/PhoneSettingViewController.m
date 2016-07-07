//
//  PhoneSettingViewController.m
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kLoginViewController_PadingLeft 23.f

#import "PhoneSettingViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "InputTextCell.h"
#import "CannotLogin.h"

@interface PhoneSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) NSTimer *countTimer;
@property (assign, nonatomic) NSInteger count;

@property (strong, nonatomic) CannotLogin *updateMobile;
@property (strong, nonatomic) User *loginUser;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSString *captcha;
@end

static const NSInteger maxCount = 60;

@implementation PhoneSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改绑定手机";
    
    //tableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[InputTextCell class] forCellReuseIdentifier:kCellIdentifier_InputTextCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kLoginViewController_PadingLeft);
            make.right.equalTo(self.view).offset(-kLoginViewController_PadingLeft);
            make.top.bottom.equalTo(self.view);
        }];
        tableView;
    });
    
    _updateMobile = [[CannotLogin alloc] init];
    
    //customer header and footer
    _myTableView.tableHeaderView = [self customerHeader];
    _myTableView.tableFooterView = [self customerFooter];
    
    _titleArray = [NSMutableArray new];
    [_titleArray addObject:@[@"手机号码",@"请输入手机号"]];
    [_titleArray addObject:@[@"验证手机",@"请输入验证码"]];
}

- (UIView *)customerHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 88.f)];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (UIView *)customerFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 150.f)];
    //login button
    _submitButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"完成" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(saveBoudingPhone)];
    [footerView addSubview:_submitButton];
    
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(35);
        make.centerX.equalTo(footerView);
        make.height.mas_equalTo(35);
        make.width.equalTo(footerView);
    }];
    
    RAC(self.submitButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, updateMobile.userMobile),RACObserve(self, captcha)]
                                                   reduce:^id (NSString *phoneStr, NSString *captcha){
                                                       return @((phoneStr && phoneStr.length > 0) && (captcha && captcha.length > 0));
                                                   }];
    
    return footerView;
}

#pragma mark - TableView
- (NSArray *)titleForRow:(NSInteger)row {
    return _titleArray[row];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [InputTextCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InputTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_InputTextCell forIndexPath:indexPath];
    [cell setTitleStr:[[self titleForRow:indexPath.row] firstObject] andPlaceholderStr:[[self titleForRow:indexPath.row] lastObject]];
    __weak typeof(self) weakSelf = self;
    switch (indexPath.row) {
        case 0: {
            cell.topRounded = YES;
            cell.inputBlock = ^(NSString *inputStr) {
                weakSelf.updateMobile.userMobile = inputStr;
            };
        }
            break;
        case 1: {
            cell.showCaptchaButton = YES;
            cell.bottomRounded = YES;
            cell.captchaClicked = ^ {
                [weakSelf getCaptchCode];
            };
            cell.inputBlock = ^(NSString *inputStr) {
                weakSelf.updateMobile.captcha = inputStr;
            };
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Action
- (void)saveBoudingPhone {
    [self.view endEditing:YES];
    if ([_updateMobile isCaptchaMatched:_captcha]) {
        __weak typeof(self) weakSelf = self;
        _submitButton.enabled = NO;
        
        _loginUser = [Login curLoginUser];
        if ([_updateMobile.userMobile isEqualToString:_loginUser.usermobile]) {
            kTipAlert(@"该手机号与当前绑定的手机号相同");
        } else {
            _loginUser.usermobile = _updateMobile.userMobile;
            [[NetAPIManager shareManager] request_get_userWithMobile:_updateMobile.userMobile andBlock:^(id data, NSError *error) {
                weakSelf.submitButton.enabled = NO;
                if (data) { //如果该手机号能查询到用户
                    kTipAlert(@"该手机号已被占用,请确认您的手机号");
                } else {
                    [[NetAPIManager shareManager] request_updateUserInfo:weakSelf.loginUser andBlock:^(id updatedData, NSError *error) {
                        if (updatedData) {
                            if ([updatedData[@"state"] intValue] == 1) {
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                                [weakSelf showHudTipStr:@"绑定手机号修改成功"];
                                if (weakSelf.changeMobileBlock) {
                                    weakSelf.changeMobileBlock();
                                }
                            }
                        }
                    }];
                }
            }];
        }
    }
}

- (void)getCaptchCode {
    __weak typeof(self) weakSelf = self;
    if (_updateMobile.userMobile && [_updateMobile.userMobile isPhoneNumber]) {
        [[NetAPIManager shareManager] request_get_captchtWithPhone:_updateMobile.userMobile andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.captcha = data[@"smscode"];
                NSLog(@"%@",weakSelf.captcha);
                kTipAlert(@"密码已发送到手机,请注意查收");
                InputTextCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                cell.captchaButton.enabled = NO;
                weakSelf.countTimer = [NSTimer scheduledTimerWithTimeInterval:1.f block:^{
                    [weakSelf buttonCount];
                } repeats:YES];
            }
        }];
    } else {
        [self showHudTipStr:@"请输入正确的手机号"];
    }
}

- (void)buttonCount {
    InputTextCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if (_count == maxCount) {
        _count = 0 ;                //重新计时
        [_countTimer invalidate];   //停止计时器
        [cell.captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        cell.captchaButton.enabled = YES;
    } else {
        [cell.captchaButton setTitle:[NSString stringWithFormat:@"剩余 %@秒",@(maxCount - _count++)] forState:UIControlStateNormal];
    }
}

- (void)resetCountTimer:(InputTextCell *)cell {
    _count = 0 ;                //重新计时
    [_countTimer invalidate];   //停止计时器
    [cell.captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    cell.captchaButton.enabled = YES;
}

@end
