//
//  SettingTextViewController.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "SettingTextViewController.h"
#import "SettingTextCell.h"

@interface SettingTextViewController () <UITableViewDataSource ,UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSString *myTextValue;
@property (strong, nonatomic) UILabel *countLabel;

@property (assign, nonatomic) BOOL canSubmit;
@end

@implementation SettingTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[SettingTextCell class] forCellReuseIdentifier:kCellIdentifier_SettingTextCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    if (_limited) {
        _myTableView.tableFooterView = [self customerFooter];
    }
    
    UIBarButtonItem *doneItem = [UIBarButtonItem itemWithBtnTitle:_textValue.length > 0?@"保存":@"确定" target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    _myTextValue = [_textValue mutableCopy];
    @weakify(self);
    RAC(doneItem, enabled) = [RACSignal combineLatest:@[RACObserve(self, myTextValue)] reduce:^id (NSString *newTextValue){
        @strongify(self);
        if (self.canSubmibNil) {
            return @(![self.textValue isEqualToString:newTextValue]);
        } else {
            return @(![self.textValue isEqualToString:newTextValue] && newTextValue.length != 0);
        }
    }];
}

- (UIView *)customerFooter {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20.f)];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.textAlignment = NSTextAlignmentRight;
    _countLabel.font = [UIFont systemFontOfSize:12.f];
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.textColor = [UIColor lightGrayColor];
    NSInteger remainCount = self.limitedCount - self.textValue.length;
    _countLabel.text = @(remainCount).stringValue;
    [footer addSubview:_countLabel];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footer).offset(kPaddingLeftWidth);
        make.right.equalTo(footer).offset(-kPaddingLeftWidth);
        make.top.equalTo(footer);
        make.bottom.equalTo(footer);
    }];
    return footer;
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    SettingTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SettingTextCell forIndexPath:indexPath];
    cell.textChangeBlock = ^(NSString *textValue){
        if (weakSelf.limited) {
            NSInteger remainCount = weakSelf.limitedCount - textValue.length;
            if (remainCount >=0 ) {
                weakSelf.canSubmit = YES;
                weakSelf.myTextValue = textValue;
            } else {
                weakSelf.canSubmit = NO;
                [weakSelf showHudTipStr:@"最多只可输入30位字符"];
            }
            weakSelf.countLabel.text = @(remainCount).stringValue;
        } else {
            weakSelf.myTextValue = textValue;
        }
    };
    [cell setTextValue:_textValue];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:self.title andHeight:30.f color:[UIColor clearColor] andBlock:nil];
}

#pragma mark - Action
- (void)submit {
    if (self.limited) {
        if (self.canSubmit) {
            [self popBlock];
        } else {
            [self showHudTipStr:@"最多只可输入30位字符"];
        }
    } else {
        [self popBlock];
    }
}

- (void)popBlock {
    if (_doneBlock) {
        _doneBlock(_myTextValue);
    }
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
