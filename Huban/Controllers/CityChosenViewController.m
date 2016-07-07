//
//  CityChosenViewController.m
//  Huban
//
//  Created by sean on 15/8/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CityChosenViewController.h"
#import "CityChosenCell.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface CityChosenViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataItems;
@property (strong, nonatomic) NSMutableIndexSet *dropDownList;

@property (strong, nonatomic) Region *curRegion;
@end

@implementation CityChosenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"城市";
    
    //tableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[CityChosenCell class] forCellReuseIdentifier:kCellIdentifier_CityChosenCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    [self loadData];
}

- (void)loadData {
    _dataItems = [[NSMutableArray alloc] init];
    _dropDownList = [NSMutableIndexSet indexSet];
    
    [_dataItems addObjectsFromArray:[[[DataBaseManager shareInstance] provinceList] sortedArrayUsingComparator:^NSComparisonResult(Province*  _Nonnull obj1, Province*  _Nonnull obj2) {
        NSString *firstProv = [obj1.provname transformToPinyin];
        NSString *secondeProv = [obj2.provname transformToPinyin];
        return [firstProv compare:secondeProv options:NSNumericSearch];
    }]];

    if (_type == RegionType_CityCircle) { //如果是同城圈选择城市
        //当前城市
        Province *curProv = [[Province alloc] init];
        curProv.provname = @"定位城市";
        Region *temRegion = [[Region alloc] init];
        temRegion.cityname = @"正在定位";
        [curProv.subRegionArray addObject:temRegion];
        [_dataItems insertObject:curProv atIndex:0];
        
        //热门城市
        Province *hotProv = [[Province alloc] init];
        hotProv.provname = @"热门城市";
        //加入北上广深杭五个城市
        [hotProv.subRegionArray addObject:[[DataBaseManager shareInstance] regionForFullName:@"北京市"]];
        [hotProv.subRegionArray addObject:[[DataBaseManager shareInstance] regionForFullName:@"上海市"]];
        [hotProv.subRegionArray addObject:[[DataBaseManager shareInstance] regionForFullName:@"深圳市"]];
        [hotProv.subRegionArray addObject:[[DataBaseManager shareInstance] regionForFullName:@"广州市"]];
        [hotProv.subRegionArray addObject:[[DataBaseManager shareInstance] regionForFullName:@"杭州市"]];
        [_dataItems insertObject:hotProv atIndex:1];
    
        [_dropDownList addIndexesInRange:NSMakeRange(0, 2)];
        
        //获取用户位置信息
        @weakify(self);
        [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
            @strongify(self);
            [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:userLocation.location.coordinate.longitude andLatitude:userLocation.location.coordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
                [self getLocationStr:location];
            }];
        }];
    }
}

- (void)getLocationStr:(BMKReverseGeoCodeResult *)placeMarks {
    NSString *cityName = placeMarks.addressDetail.city; //获取到坐标的城市名称
    _curRegion = [[DataBaseManager shareInstance] regionForFullName:cityName];
    
    Province *curProv = [[Province alloc] init];
    curProv.provname = @"定位城市";
    [curProv.subRegionArray addObject:_curRegion];
    [_dataItems replaceObjectAtIndex:0 withObject:curProv];
    
    [self.myTableView reloadData];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL dropDown = [_dropDownList containsIndex:indexPath.section];
    Province *curProvince = _dataItems[indexPath.section];
    return [CityChosenCell cellHeightWithDataItms:curProvince.subRegionArray andDropList:dropDown];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    CityChosenCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CityChosenCell forIndexPath:indexPath];
    
    if (_type == RegionType_CityCircle) { //如果是选择的朋友圈
        if (indexPath.section == 0 || indexPath.section == 1) {
            cell.showIndicator = NO;
        } else {
            cell.showIndicator = YES;
            cell.groupTitleTapBlock = ^(BOOL hasDropDown){
                if (hasDropDown) {
                    [weakSelf.dropDownList addIndex:indexPath.section];
                } else {
                    [weakSelf.dropDownList removeIndex:indexPath.section];
                }
                [weakSelf.myTableView reloadData];
            };
        }
    } else {
        cell.showIndicator = YES;
        cell.groupTitleTapBlock = ^(BOOL hasDropDown){
            if (hasDropDown) {
                [weakSelf.dropDownList addIndex:indexPath.section];
            } else {
                [weakSelf.dropDownList removeIndex:indexPath.section];
            }
            [weakSelf.myTableView reloadData];
        };
    }
    
    BOOL dropDown = [_dropDownList containsIndex:indexPath.section];
    [cell checkState:dropDown];
    cell.itemClickedBlock = ^(Region *selectedRegion) {
        if (weakSelf.selectedRegionBlock) {
            weakSelf.selectedRegionBlock(selectedRegion);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    Province *curProv = _dataItems[indexPath.section];
    if (_type == RegionType_CityCircle) {
        [cell setGroupTitleStr:curProv.provname];
    } else {
       [cell setGroupTitleStr:curProv.provname];
    }
    cell.dataItems = curProv.subRegionArray;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

@end
