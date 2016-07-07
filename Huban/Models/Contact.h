//
//  Contact.h
//  Huban
//
//  Created by sean on 15/10/9.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject
@property (strong, nonatomic) NSNumber *id, *blocked, *rosterid, *spamshield, *valid, *viewpermit;
@property (strong, nonatomic) NSString *contactcode, *contactemail, *contactletter, *contactlogourl ,*contactmemo, *contactmobile, *contactname, *contactuid, *holdercode, *holdername, *confirmmemo;
@property (strong, nonatomic) NSDate *createdate;


- (NSString *)toPath;

- (NSDictionary *)addedParams;
- (NSDictionary *)deletedParams;
- (NSDictionary *)blockParams;
- (NSDictionary *)changeMemoParams;
- (NSDictionary *)changeSpamshieldParams;
@end
