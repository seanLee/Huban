//
//  MessageSettingViewController.m
//  Huban
//
//  Created by sean on 15/7/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "MessageSettingViewController.h"
#import "TitleAndSwitchCell.h"

@interface MessageSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSArray *titleArr;
@end

@implementation MessageSettingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"消息管理";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TitleAndSwitchCell class] forCellReuseIdentifier:kCellIdentifier_TitleAndSwitchCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _titleArr = @[@[@"接收新消息通知"],
                  @[@"提醒时显示消息内容",@"声音",@"振动"]];
}

- (NSArray *)titleArray:(NSInteger)section {
    return _titleArr[section];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self titleArray:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleAndSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleAndSwitchCell forIndexPath:indexPath];
    cell.haveSwitchSettingBlock = ^(BOOL selected){
        NSLog(@"%@",selected?@"是":@"否");
    };
    [cell setTitleStr:[self titleArray:indexPath.section][indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    if (indexPath.section == 0) {
        float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(sysVer < 8){
            cell.switchSelected = !([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone);
        }else{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            cell.switchSelected = !([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone);
#endif
        }
        cell.canSwitch = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == 0?40.f:0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor clearColor];
    
    UILabel *textL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - kPaddingLeftWidth, 40.f)];
    textL.text = @"请在IPhone的\"设置\" - \"通知\"中进行修改";
    textL.font = [UIFont systemFontOfSize:12.f];
    textL.textColor = [UIColor grayColor];
    
    [footer addSubview:textL];
    return footer;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
