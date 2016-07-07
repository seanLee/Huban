//
//  LocationManager.m
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "LocationManager.h"
#import "CLLocation+YCLocation.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


@interface LocationManager () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (strong, nonatomic) BMKLocationService *locationManager;
@property (strong, nonatomic) BMKGeoCodeSearch *geocodeSearch;

@property (copy, nonatomic) void (^locationBlock)(BMKUserLocation *userLocation);
@property (copy, nonatomic) void (^reverseGeocodeLocationBlock)(BMKReverseGeoCodeResult *result);
@end

@implementation LocationManager
+ (instancetype)shareInstance {
    static LocationManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (void)dealloc {
    _locationManager.delegate = nil;
    _geocodeSearch.delegate = nil;
}

- (void)requestAuthorization {
    _locationManager = [[BMKLocationService alloc] init];
    _geocodeSearch = [[BMKGeoCodeSearch alloc] init];
}

- (void)getLocationWithBlock:(void (^)(BMKUserLocation *))block {
    _locationBlock = block;
    _locationManager.delegate = self;
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager startUserLocationService];
    } else {
        kTipAlert(@"需要开启定位服务,请到设置->隐私,打开定位服务");
    }
}

- (void)reverseGeocodeLocationWithLongtitude:(double)lon andLatitude:(double)lat withBlock:(void (^)(BMKReverseGeoCodeResult *))block {
    self.reverseGeocodeLocationBlock = block;
    CLLocationCoordinate2D point = {lat,lon};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = point;
    //设置委托
    _geocodeSearch.delegate = self;
   [_geocodeSearch reverseGeoCode:reverseGeocodeSearchOption];
}

- (int)getDistanceForPoint:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2 {
    BMKMapPoint curPoint = BMKMapPointForCoordinate(point1);
    BMKMapPoint userPoint = BMKMapPointForCoordinate(point2);
    return BMKMetersBetweenMapPoints(curPoint,userPoint);
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (self.reverseGeocodeLocationBlock && result) {
        self.reverseGeocodeLocationBlock(result);
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    if (self.locationBlock) {
        self.locationBlock(userLocation);
    }
    //获取到一次用户位置之后就停止定位
    [self.locationManager stopUserLocationService];
}
@end
