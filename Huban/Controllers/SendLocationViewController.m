//
//  SendLocationViewController.m
//  Huban
//
//  Created by sean on 15/12/2.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "SendLocationViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "SendLocationCell.h"

@interface SendLocationViewController () <BMKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKPointAnnotation *annotation;
@property (strong, nonatomic) BMKReverseGeoCodeResult *currentLocation;

@property (strong, nonatomic) BMKReverseGeoCodeResult *myLocation;

@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *dataItems;

@property (strong, nonatomic) UIButton *myLocationButton;

@property (assign, nonatomic) NSInteger selectedIndex;
@end

@implementation SendLocationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发送位置信息";
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonClicked)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    _myTableView = [[UITableView alloc] init];
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _myTableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    [_myTableView registerClass:[SendLocationCell class] forCellReuseIdentifier:kCellIdentifier_SendLocationCell];
    [self.view addSubview:_myTableView];
    
    _mapView = [[BMKMapView alloc] init];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.zoomLevel = 17;
    _mapView.maxZoomLevel = 19;
    [self.view addSubview:_mapView];
    
    _myLocationButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_myLocationButton setImage:[UIImage imageNamed:@"setMyLocation"] forState:UIControlStateNormal];
    [_myLocationButton addTarget:self action:@selector(resetMyLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_myLocationButton];
    
    [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_myTableView.mas_top);
    }];
    [_myLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(21.f);
        make.right.equalTo(self.view).offset(-kPaddingLeftWidth);
        make.bottom.equalTo(_myTableView.mas_top).offset(-kPaddingLeftWidth);
    }];
    
    //初始化数据
    _dataItems = [[NSMutableArray alloc] init];
    _selectedIndex = NSNotFound;
    
    [self initLocationInfo];
}

- (void)initLocationInfo {
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        //设置地图的中心为用户用户当前的坐标
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        //显示用户当前的坐标
        [self.mapView updateLocationData:userLocation];
        //记录用户当前的信息
        [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:userLocation.location.coordinate.longitude andLatitude:userLocation.location.coordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
            self.myLocation = location;
        }];
        //在用户坐标上加入一个锚点
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = userLocation.location.coordinate;
        [self.mapView addAnnotation:annotation];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self mapView:self.mapView regionDidChangeAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView onDrawMapFrame:(BMKMapStatus *)status {
    BMKPointAnnotation *annotation = [mapView.annotations firstObject];
    annotation.coordinate = mapView.centerCoordinate;
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    @weakify(self);
    [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:mapView.centerCoordinate.longitude andLatitude:mapView.centerCoordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
        @strongify(self);
        self.currentLocation = location;
        [self.myTableView reloadData];
    }];
    
}

#pragma mark - Action
- (void)sendButtonClicked {
    if (self.didClickedSendButtonBlock) {
        if (self.selectedIndex == NSNotFound) {
            NSString *poiName = [NSString stringWithFormat:@"%@%@",_currentLocation.addressDetail.district,_currentLocation.addressDetail.streetName];
             self.didClickedSendButtonBlock(_currentLocation.location.longitude,_currentLocation.location.latitude,[NSString stringWithFormat:@"%@,%@",poiName,_currentLocation.address]);
        } else {
            BMKPoiInfo *poiInfo = self.currentLocation.poiList[_selectedIndex];
            self.didClickedSendButtonBlock(poiInfo.pt.longitude,poiInfo.pt.latitude,[NSString stringWithFormat:@"%@,%@",poiInfo.name,poiInfo.address]);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma makr - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentLocation.poiList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SendLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_SendLocationCell forIndexPath:indexPath];
    BMKPoiInfo *poiInfo = self.currentLocation.poiList[indexPath.row];
    [cell setName:poiInfo.name];
    [cell setAddress:poiInfo.address];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SendLocationCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndex = indexPath.row;
    [self.myTableView reloadData];
    
    BMKPoiInfo *poiInfo = self.currentLocation.poiList[indexPath.row];
    BMKPointAnnotation *annotation = [self.mapView.annotations firstObject];
    annotation.coordinate = poiInfo.pt;
}

#pragma mark - Action
- (void)resetMyLocation:(id)sender {
    //设置地图的中心为用户用户当前的坐标
    [self.mapView setCenterCoordinate:self.myLocation.location animated:YES];
}
@end
