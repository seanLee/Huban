//
//  LoginViewController.m
//  Huban
//
//  Created by sean on 15/7/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kLoginViewController_PadingLeft 23.f

#import "LoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "InputTextWithIconCell.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "ForgetCodeViewController.h"

@interface LoginViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"呼伴";
    // Do any additional setup after loading the view.
    //tableview
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.showsVerticalScrollIndicator = NO;
        [tableView registerClass:[InputTextWithIconCell class] forCellReuseIdentifier:kCellIdentifier_InputTextWithIconCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kLoginViewController_PadingLeft);
            make.right.equalTo(self.view).offset(-kLoginViewController_PadingLeft);
            make.top.bottom.equalTo(self.view);
        }];
        tableView;
    });
    //the login object
    _curLogin = [[Login alloc] init];
    _curLogin.userMobile = [Login lastLoginCode];
    
    self.myTableView.tableHeaderView = [self customerHeader];
    self.myTableView.tableFooterView = [self customerFooter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshIconUserImage];
}

- (void)refreshIconUserImage {
    NSString *textStr = self.curLogin.userMobile;
    if (textStr && ![textStr isEmpty]) {
        User *curUser = [Login userWithMobile:textStr];
        if (curUser && curUser.userlogourl) {
            [self.headerImageView sd_setImageWithURL:[NSURL thumbImageURLWithString:curUser.userlogourl] placeholderImage:[UIImage avatarPlacer]];
        }
    }
}

- (UIView *)customerHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 185.f)];
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75.f, 75.f)];
    _headerImageView.layer.cornerRadius = 5.f;
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.image = [UIImage imageNamed:@"placeholderHeaderImage"];
    [header addSubview:_headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(75);
        make.center.equalTo(header);
    }];
    return header;
}

- (UIView *)customerFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_myTableView.frame), 150.f)];
    //register button
    UIButton *registerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50.f, 24.f)];
    registerButton.titleLabel.font = kBaseFont;
    registerButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [registerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [registerButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [registerButton setTitle:@"注册账号" forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(gotoRegister) forControlEvents:UIControlEventTouchUpInside];
    [registerButton sizeToFit];
    [footerView addSubview:registerButton];
    
    //fogetPassword button
    UIButton *forgetPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(100.f, 0, 50.f, 24.f)];
    forgetPasswordButton.titleLabel.font = kBaseFont;
    forgetPasswordButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [forgetPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [forgetPasswordButton setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    [forgetPasswordButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetPasswordButton addTarget:self action:@selector(forgetCode) forControlEvents:UIControlEventTouchUpInside];
    [forgetPasswordButton sizeToFit];
    [footerView addSubview:forgetPasswordButton];
    
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView);
        make.top.equalTo(footerView).offset(9);
    }];
    
    [forgetPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(footerView);
        make.top.equalTo(footerView).offset(9);
    }];
    
    //login button
    _loginButton = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(0, 0, 100.f, 24.f) target:self action:@selector(login)];
    [footerView addSubview:_loginButton];
    
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(registerButton.mas_bottom).offset(kPaddingLeftWidth);
        make.centerX.equalTo(footerView);
        make.height.mas_equalTo(35);
        make.width.equalTo(footerView);
    }];
    
    RAC(self.loginButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, curLogin.userMobile),
                                                           RACObserve(self, curLogin.userPass)]
                                                    reduce:^id(NSString *username,NSString *password){
                                                        return @((username && username.length > 0) && (password && password.length > 0));
                                                    }];
    
    return footerView;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [InputTextWithIconCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    InputTextWithIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_InputTextWithIconCell forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == 0) {
        cell.placeholderStr = @"请输入手机号";
        cell.lastLoginCode = self.curLogin.userMobile;
        cell.iconImage = [UIImage imageNamed:@"login_icon_account"];
        cell.topRounded = YES;
        cell.textValueChangedBlock = ^(NSString *str) {
            weakSelf.curLogin.userMobile = str;
            [weakSelf.headerImageView setImage:[UIImage avatarPlacer]];
        };
        cell.textDidEndEditingBlock = ^(NSString *str) {
            [weakSelf refreshIconUserImage];
        };
    } else if (indexPath.row == 1) {
        cell.placeholderStr = @"请输入密码";
        cell.isSecret = YES;
        cell.iconImage = [UIImage imageNamed:@"login_icon_pwd"];
        cell.bottomRounded = YES;
        cell.textValueChangedBlock = ^(NSString *str) {
            weakSelf.curLogin.userPass = str;
        };
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Action
- (void)login {
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    _loginButton.enabled = NO;
    if ([_curLogin canLogin]) {
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            CGSize captchaViewSize = _loginButton.bounds.size;
            _activityIndicator.hidesWhenStopped = YES;
            [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
            [_loginButton addSubview:_activityIndicator];
        }
        [_activityIndicator startAnimating];
        //实现登录
        [[NetAPIManager shareManager] request_login_withParams:weakSelf.curLogin andBlock:^(id data, NSError *error) {
            [weakSelf.activityIndicator stopAnimating];
            weakSelf.loginButton.enabled = YES;
            if (data) {
                //纪录登录session
                NSUserDefaults *defauls = [NSUserDefaults standardUserDefaults];
                [defauls setObject:data[@"session"] forKey:kSession];
                [defauls synchronize];
                //保存用户登录时的帐号,下次登录时显示
                [Login saveLastLoginCode:weakSelf.curLogin.userMobile];
                //登录后获取登录用户信息
                [[NetAPIManager shareManager] request_get_userWithMobile:weakSelf.curLogin.userMobile andBlock:^(id objectData, NSError *error) {
                    if (objectData) {
                        [Login doLogin:objectData completion:^{
                            //登录环信
                            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[Login curLoginUser].usercode password:[Login curLoginUser].userPass completion:^(NSDictionary *loginInfo, EMError *error) {
                                //设置自动登录
                                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                                EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                                [[EaseMob sharedInstance].chatManager updatePushOptions:options error:nil];
                                //切换到主界面
                                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTabBarViewController];
                            } onQueue:dispatch_get_main_queue()];
                        }];
                    }
                }];
            }
        }];
    }
}

- (void)gotoRegister {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)forgetCode {
    ForgetCodeViewController *forgetCodeVC = [[ForgetCodeViewController alloc] init];
    [self.navigationController pushViewController:forgetCodeVC animated:YES];
}
@end
