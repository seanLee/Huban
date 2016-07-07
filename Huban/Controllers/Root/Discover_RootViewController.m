//
//  Discover_RootViewController.m
//  Huban
//
//  Created by sean on 15/7/26.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "Discover_RootViewController.h"
#import "TitleLeftIconCell.h"
#import "FriendsCircleViewController.h"
#import "HallLocationViewController.h"
#import "PhoneChatViewController.h"
#import "AroundViewController.h"
#import "LocationAuthViewController.h"

@interface Discover_RootViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataLists;
@end

@implementation Discover_RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发现";
    
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableview registerClass:[TitleLeftIconCell class] forCellReuseIdentifier:kCellIdentifier_TitleLeftIconCell];
        [self.view addSubview:tableview];
        [tableview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableview;
    });
    
    [self setupDataList];
}

- (void)setupDataList {
    _dataLists = [NSMutableArray array];
    [_dataLists addObject:@[@[@"好友生活",@"discover_circle"]]];
    [_dataLists addObject:@[@[@"周边的人",@"discover_around"]
                            ,@[@"候厅热聊",@"discover_hall"]
                            //                            ,@[@"电话对对碰",@"discover_phone"]
                            ]];
}

- (NSInteger)valueListForSection:(NSInteger)section {
    NSArray *curArray = [_dataLists objectAtIndex:section];
    return curArray.count;
}

- (NSArray *)titleStrAndImageForIndexPath:(NSIndexPath *)indexPath {
    return _dataLists[indexPath.section][indexPath.row];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self valueListForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleLeftIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleLeftIconCell forIndexPath:indexPath];
    [cell setTitle:[[self titleStrAndImageForIndexPath:indexPath] firstObject]
              icon:[[self titleStrAndImageForIndexPath:indexPath] lastObject]];
    cell.showIndicator = YES;
    if (indexPath.section == 0) {
        cell.hasNewIndicator = YES;
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TitleLeftIconCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseViewController *baseVC = nil;
    if (indexPath.section == 0) {
        baseVC = [[FriendsCircleViewController alloc] init];
    } else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0: {
                NSNumber *locationAuth = [[NSUserDefaults standardUserDefaults] objectForKey:kLocationAuth];
                if (locationAuth.boolValue) {
                    baseVC = [[AroundViewController alloc] init];
                } else {
                    baseVC = [[LocationAuthViewController alloc] init];
                }
            }
                break;
            case 1:
                baseVC = [[HallLocationViewController alloc] init];
                break;
            default:
                baseVC = [[PhoneChatViewController alloc] init];
                break;
        }
    }
    [self.navigationController pushViewController:baseVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil] ;
}
@end
