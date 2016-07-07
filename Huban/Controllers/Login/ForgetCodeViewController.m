//
//  ForgetCodeViewController.m
//  Huban
//
//  Created by sean on 15/8/10.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kLoginViewController_PadingLeft 23.f

#import "ForgetCodeViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "InputTextCell.h"
#import "CannotLogin.h"

@interface ForgetCodeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) CannotLogin *cannotLogin;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) NSMutableArray *titleArray;
@property (strong, nonatomic) NSString *captcha;
@property (strong, nonatomic) NSTimer *countTimer;
@property (assign, nonatomic) NSInteger count; 
@end

@implementation ForgetCodeViewController

static const NSInteger maxCount = 60;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"忘记密码";
    
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
    
    //create register object
    _cannotLogin = [[CannotLogin alloc] init];
    _cannotLogin.operationType = CannotLoginTypeModefyCode;
    
    //customer header and footer
    _myTableView.tableHeaderView = [self customerHeader];
    _myTableView.tableFooterView = [self customerFooter];
    
    _titleArray = [NSMutableArray new];
    [_titleArray addObject:@[@"手机号码",@"请输入手机号"]];
    [_titleArray addObject:@[@"设置密码",@"请输入密码"]];
    [_titleArray addObject:@[@"确认密码",@"请重复密码"]];
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
    UIButton *submitButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"确定" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(submit)];
    [footerView addSubview:submitButton];
    
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(footerView).offset(35);
        make.centerX.equalTo(footerView);
        make.height.mas_equalTo(35);
        make.width.equalTo(footerView);
    }];
    
    RAC(submitButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, cannotLogin.userMobile),RACObserve(self, cannotLogin.userPass),
                                                            RACObserve(self, cannotLogin.repeatPass),RACObserve(self, cannotLogin.captcha)]
                                                   reduce:^id (NSString *username, NSString *code,
                                                               NSString *repeatCode, NSString *captcha){
                                                       return @((username && username.length > 0) && (code && code.length > 0)
                                                       && (repeatCode && repeatCode.length > 0) && (captcha && captcha.length > 0));
                                                   }];
    
    return footerView;
}

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
                weakSelf.cannotLogin.userMobile = inputStr;
            };
        }
            break;
        case 1: {
            cell.isSecret = YES;
            cell.inputBlock = ^(NSString *inputStr) {
                weakSelf.cannotLogin.userPass = inputStr;
            };
        }
            break;
        case 2: {
            cell.isSecret = YES;
            cell.inputBlock = ^(NSString *inputStr) {
                weakSelf.cannotLogin.repeatPass = inputStr;
            };
        }
            break;
        case 3: {
            cell.inputBlock = ^(NSString *inputStr) {
                weakSelf.cannotLogin.captcha = inputStr;
            };
            cell.captchaClicked = ^ {
                [weakSelf getCaptchCode];
            };
            cell.showCaptchaButton = YES;
            cell.bottomRounded = YES;
        }
            break;
            
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - Action
- (void)submit {
    __weak typeof(self) weakSelf = self;
    if ([_cannotLogin isCaptchaMatched:_captcha]) {
        if ([_cannotLogin canSubmit]) {
            [[NetAPIManager shareManager] request_modefyCode_withParams:_cannotLogin andBlock:^(id data, NSError *error) {
                if (data) {
                    [self showHudTipStr:@"密码修改成功,请使用新密码登录"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
}

#pragma mark - Private
- (void)getCaptchCode {
    __weak typeof(self) weakSelf = self;
    if (_cannotLogin.userMobile && [_cannotLogin.userMobile isPhoneNumber]) {
        [[NetAPIManager shareManager] request_get_codeWithParams:_cannotLogin andBlock:^(id data, NSError *error) {
            if (data) {
                weakSelf.captcha = data[@"smscode"];
                weakSelf.cannotLogin.rndCode = data[@"rndcode"];
                NSLog(@"%@",weakSelf.captcha);
                kTipAlert(@"密码已发送到手机,请注意查收");
                InputTextCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
                cell.captchaButton.enabled = NO;
                weakSelf.countTimer = [NSTimer scheduledTimerWithTimeInterval:1.f block:^{
                    [weakSelf buttonCount];
                } repeats:YES];
            }
        }];
    }
}

- (void)buttonCount {
    InputTextCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    if (_count == maxCount) {
        _count = 0 ;                //重新计时
        [_countTimer invalidate];   //停止计时器
        [cell.captchaButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        cell.captchaButton.enabled = YES;
    } else {
        [cell.captchaButton setTitle:[NSString stringWithFormat:@"剩余 %@秒",@(maxCount - _count++)] forState:UIControlStateNormal];
    }
}
@end
