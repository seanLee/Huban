//
//  User.h
//  Huban
//
//  Created by sean on 15/7/23.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (strong, nonatomic) NSNumber *usertype, *userstate, *usersex, *userrank, *userage, *usercredit, *uservitality, *logintimes;
@property (strong, nonatomic) NSString *usercode, *useruid, *usermobile, *useremail, *userPass, *username, *usersign, *userlogourl, *certifymemo, *certifyfile, *userTrends;
@property (strong, nonatomic) NSString *provcode, *provname, *citycode, *cityname, *invitecode;
@property (strong, nonatomic) NSDate *certifydate, *updatedate, *createdate;
@property (strong, nonatomic) NSNumber *updatelon, *updatelat, *updategeotype, *updatedevtype;
@property (strong, nonatomic) NSString *updateprovcode, *updatecitycode, *updatelocation, *updatehostaddr, *updatedevcode, *updateappcode;
@property (strong, nonatomic) NSNumber *certified, *needconfirm, *spamshield, *viewpermit, *valid; //权限

- (id)initWithUserCode:(NSString *)userCode;

- (NSString *)toUpdatePath;

- (NSDictionary *)toUpdateParams;
- (NSDictionary *)refreshLocationParams;
- (NSDictionary *)toUpdateRegionParams;

- (NSInteger)distanceMeters;
- (UIColor *)sexColor;
- (UIImage *)sexIcon;
@end
