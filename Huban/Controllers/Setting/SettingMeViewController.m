//
//  SettingMeViewController.m
//  Huban
//
//  Created by sean on 15/8/5.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "SettingMeViewController.h"
#import "TitleValueMoreCell.h"
#import "TitleRImageMoreCell.h"

@interface SettingMeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *titleArr;
@property (strong, nonatomic) NSMutableArray *textArr;
@end

@implementation SettingMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"个人信息";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleValueMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleValueMore];
        [tableView registerClass:[TitleRImageMoreCell class] forCellReuseIdentifier:kCellIdentifier_TitleRImageMore];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self setupTitles];
}

- (void)setupTitles {
    _titleArr = [NSMutableArray new];
    [_titleArr addObject:@[@"头像",@"昵称",@"呼伴账号"]];
    [_titleArr addObject:@[@"性别",@"地区",@"个人签名"]];
    
    _textArr = [NSMutableArray new];
    [_textArr addObject:@[@"头像",@"Sean",@"未设置"]];
    [_textArr addObject:@[@"男",@"湖北武汉",@"测试数据测试数据测试数据测试数据测试数据测试数据测试数据测试数据测试数"]];
}

- (NSString *)titleForIndexpath:(NSIndexPath *)indexPath {
    NSArray *titles = _titleArr[indexPath.section];
    return titles[indexPath.row];
}

- (NSString *)textForIndexpath:(NSIndexPath *)indexPath {
    NSArray *titles = _textArr[indexPath.section];
    return titles[indexPath.row];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *titles = _titleArr[section];
    return titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return [TitleRImageMoreCell cellHeight];
    }
    return [TitleValueMoreCell cellHeightWithStr:[self textForIndexpath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        TitleRImageMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleRImageMore forIndexPath:indexPath];
        cell.curUser = [User new];
        [cell setTitleStr:[self titleForIndexpath:indexPath]];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    TitleValueMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleValueMore forIndexPath:indexPath];
    [cell setTitleStr:[self titleForIndexpath:indexPath] valueStr:[self textForIndexpath:indexPath]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
