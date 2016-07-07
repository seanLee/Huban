//
//  Me_RootViewController.m
//  Huban
//
//  Created by sean on 15/7/26.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "Me_RootViewController.h"
#import "SettingViewController.h"
#import "CharacterCell.h"
#import "MyCollectionViewController.h"
#import "TitleLeftIconCell.h"
#import "AlbumViewController.h"

@interface Me_RootViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataLists;
@property (strong, nonatomic) NSArray *iconImageArray;
@end

@implementation Me_RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的";
    //setup
    _myTableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableview.dataSource = self;
        tableview.delegate = self;
        tableview.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableview registerClass:[TitleLeftIconCell class] forCellReuseIdentifier:kCellIdentifier_TitleLeftIconCell];
        [tableview registerClass:[CharacterCell class] forCellReuseIdentifier:kCellIdentifier_CharacterCell];
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
    [_dataLists addObject:@[@""]];
    [_dataLists addObject:@[@"相册",@"收藏",@"设置"]];
    
    _iconImageArray = @[@"my_album",@"my_colletcion",@"my_setting"];
}

- (NSInteger)valueListForSection:(NSInteger)section {
    if (section < _dataLists.count) {
        NSArray *curArray = [_dataLists objectAtIndex:section];
        return curArray.count;
    }
    return 0;
}

- (NSString *)titleStrForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < _dataLists.count) {
        NSArray *curArray = [_dataLists objectAtIndex:indexPath.section];
        return [curArray objectAtIndex:indexPath.row];
    }
    return @"";
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataLists.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self valueListForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CharacterCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CharacterCell forIndexPath:indexPath];
        cell.curUser = [Login curLoginUser];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
    TitleLeftIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleLeftIconCell forIndexPath:indexPath];
    cell.showIndicator = YES;
    [cell setTitle:[self titleStrForIndexPath:indexPath] icon:_iconImageArray[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
      return [[CharacterCell class] cellHeight];
    }
    return [TitleLeftIconCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                AlbumViewController *vc = [[AlbumViewController alloc] init];
                Contact *relation = [[Contact alloc] init];
                relation.contactcode = [Login curLoginUser].usercode;
                vc.relation = relation;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1: {
                MyCollectionViewController *vc = [[MyCollectionViewController alloc] init];
                vc.userCode = [Login curLoginUser].usercode;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2: {
                SettingViewController *vc = [[SettingViewController alloc] init];
                vc.refreshBlock = ^ {
                    [weakSelf.myTableView reloadData];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kScaleFrom_iPhone5_Desgin(10);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:nil andHeight:kScaleFrom_iPhone5_Desgin(10) andBlock:nil] ;
}
@end
