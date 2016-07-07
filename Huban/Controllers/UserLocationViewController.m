//
//  UserLocationViewController.m
//  Huban
//
//  Created by sean on 15/12/1.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "UserLocationViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface UserLocationViewController () <BMKMapViewDelegate>
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKPointAnnotation *annotation;
@property (strong, nonatomic) BMKReverseGeoCodeResult *currentLocation;
@end

@implementation UserLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置信息";

    _mapView = [[BMKMapView alloc] init];
    _mapView.showsUserLocation = NO;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.zoomLevel = 17;
    _mapView.maxZoomLevel = 19;
    
    [self.view addSubview:_mapView];
    
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        //设置地图的中心为用户用户当前的坐标
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        //显示用户当前的坐标
        [self.mapView updateLocationData:userLocation];
        //在用户坐标上加入一个锚点
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
        annotation.coordinate = userLocation.location.coordinate;
        [self.mapView addAnnotation:annotation];
    }];
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
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
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
    }];

}

#pragma mark - Action
- (void)sendButtonClicked {
    if (self.didClickedSendButtonBlock) {
        self.didClickedSendButtonBlock(self.currentLocation);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
