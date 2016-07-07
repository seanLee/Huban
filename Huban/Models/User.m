//
//  User.m
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "User.h"
#import <CoreLocation/CoreLocation.h>

@implementation User
- (id)init {
    self = [super init];
    if (self) {
        _userage = @0;
    }
    return self;
}

- (id)initWithUserCode:(NSString *)userCode {
    self = [super init];
    if (self) {
        _usercode = userCode;
    }
    return self;
}

- (NSString *)toUpdatePath {
    return @"router";
}

- (NSDictionary *)toUpdateParams {
    return @{@"method":@"user.update",@"usercode":_usercode,
             @"useruid":_useruid,@"usermobile":_usermobile,
             @"useremail":_useremail,@"username":_username,
             @"usersign":_usersign,@"userlogourl":_userlogourl,
             @"usersex":_usersex};
}
- (NSDictionary *)refreshLocationParams {
    return @{@"method":@"common.logdevice.create",@"devicecode":[NSString stringWithFormat:@"JPUSH-%@",[APService registrationID]?:@""],
             @"devicetype":kCode_DeviceType.stringValue,@"geotype":kGeotype,
             @"longitude":_updatelon,@"latitude":_updatelat,@"devicename":[APService registrationID]};
}
- (NSDictionary *)toUpdateRegionParams {
    return @{@"method":@"user.chgregion",@"usercode":_usercode,@"citycode":_citycode,@"cityname":_cityname,
             @"provcode":_provcode,@"provname":_provname};
}

- (UIColor *)sexColor {
    UIColor *sexColor;
    if (self.usersex.intValue == 1) { //1表示男性
        sexColor = [UIColor colorWithHexString:@"0x6597f5"];
    } else {
        sexColor = [UIColor colorWithHexString:@"0xeb80ba"];
    }
    return sexColor;
}

- (UIImage *)sexIcon {
    UIImage *sexIcon;
    if (self.usersex.intValue == 1) { //1表示男性
        sexIcon = [UIImage imageNamed:@"icon_male"];
    } else {
        sexIcon = [UIImage imageNamed:@"icon_female"];
    }
    return sexIcon;
}

- (NSNumber *)userrank {
    if (_userrank) {
        return _userrank;
    }
    return @(0);
}

- (NSNumber *)usercredit {
    if (_usercredit) {
        return _usercredit;
    }
    return @(0);
}

- (NSInteger)distanceMeters {
    NSInteger distance = 0;
    User *loginUser = [Login curLoginUser];
    if (![_useruid isEqualToString:loginUser.useruid]) {
        CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:_updatelat.doubleValue longitude:_updatelon.doubleValue];
        CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:loginUser.updatelat.doubleValue longitude:loginUser.updatelon.doubleValue];
        distance = [curLocation distanceFromLocation:originLocation];
        if (distance < 100) { //最小距离为100m
            distance = 100;
        }
    }
    return distance;
}
@end
