//
//  UserLocationViewController.m
//  Huban
//
//  Created by sean on 15/12/1.
//  Copyright © 2015年 sean. All rights reserved.
//

#define kLocationLabelHeight 60.f

#import "LocationDetailViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface LocationDetailViewController () <BMKMapViewDelegate>
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKPointAnnotation *annotation;

@property (strong, nonatomic) BMKReverseGeoCodeResult *myLocation;

@property (strong, nonatomic) UIView *locationView;
@property (strong, nonatomic) UILabel *locationNameLbl;
@property (strong, nonatomic) UILabel *locationAddressLbl;
@property (strong, nonatomic) UIButton *myLocationButton;
@end

@implementation LocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"位置信息";
    {
        _mapView = [[BMKMapView alloc] init];
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = YES;//显示定位图层
        _mapView.zoomLevel = 17;
        _mapView.maxZoomLevel = 19;
        [self.view addSubview:_mapView];
    }
    {
        _locationView = [[UIView alloc] init];
        _locationView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        [self.view addSubview:_locationView];
        
        _locationNameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationNameLbl.font = [UIFont systemFontOfSize:14.f];
        _locationNameLbl.textColor = SYSFONTCOLOR_BLACK;
        [_locationView addSubview:_locationNameLbl];
        
        _locationAddressLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _locationAddressLbl.font = [UIFont systemFontOfSize:12.f];
        _locationAddressLbl.textColor = [UIColor lightGrayColor];
        [_locationView addSubview:_locationAddressLbl];
    }
    {
        _myLocationButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_myLocationButton setImage:[UIImage imageNamed:@"setMyLocation"] forState:UIControlStateNormal];
        [_myLocationButton addTarget:self action:@selector(resetMyLocation:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_myLocationButton];
    }
    [_mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(_locationView.mas_top);
    }];
    [_locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(kLocationLabelHeight);
    }];
    [_locationNameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_locationView);
        make.left.equalTo(_locationView).offset(kPaddingLeftWidth);
        make.right.equalTo(_locationView).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo(kLocationLabelHeight/2);
    }];
    [_locationAddressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_locationView);
        make.left.equalTo(_locationView).offset(kPaddingLeftWidth);
        make.right.equalTo(_locationView).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo(kLocationLabelHeight/2);
    }];
    [_myLocationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(21.f);
        make.right.equalTo(self.view).offset(-kPaddingLeftWidth);
        make.bottom.equalTo(_locationView.mas_top).offset(-kPaddingLeftWidth);
    }];
    
    [self initLocationInfo];
    
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = (CLLocationCoordinate2D){self.message.latitude,self.message.longitude};
    [self.mapView addAnnotation:annotation];
    //设置mapview的中点
    [self.mapView setCenterCoordinate:annotation.coordinate];
    
    NSArray *locationInfo = [self.message.address componentsSeparatedByString:@","];
    _locationNameLbl.text = [locationInfo firstObject];
    _locationAddressLbl.text = [locationInfo lastObject];
}


- (void)initLocationInfo {
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        //显示用户当前的坐标
        [self.mapView updateLocationData:userLocation];
        //记录用户当前的信息
        [[LocationManager shareInstance] reverseGeocodeLocationWithLongtitude:userLocation.location.coordinate.longitude andLatitude:userLocation.location.coordinate.latitude withBlock:^(BMKReverseGeoCodeResult *location) {
            self.myLocation = location;
        }];
    }];
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
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

#pragma mark - Action
- (void)resetMyLocation:(id)sender {
    //设置地图的中心为用户用户当前的坐标
    [self.mapView setCenterCoordinate:self.myLocation.location animated:YES];
}
@end
