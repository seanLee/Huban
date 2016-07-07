//
//  LocationManager.h
//  Huban
//
//  Created by sean on 15/10/8.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@class BMKUserLocation;
@class BMKReverseGeoCodeResult;

@interface LocationManager : NSObject
+ (instancetype)shareInstance;

- (void)requestAuthorization;
- (void)getLocationWithBlock:(void (^)(BMKUserLocation *userLocation))block;
- (void)reverseGeocodeLocationWithLongtitude:(double)lon andLatitude:(double)lat withBlock:(void (^)(BMKReverseGeoCodeResult *location))block;
- (int)getDistanceForPoint:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2;
@end