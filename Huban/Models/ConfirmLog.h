//
//  ConfirmLog.h
//  Huban
//
//  Created by sean on 15/10/9.
//  Copyright © 2015年 sean. All rights reserved.
//

typedef NS_ENUM(NSInteger, ConfirmType) {
    ConfirmType_AddUser = 0,
    ConfirmType_DeleteUser,
    ConfirmType_AddedByGroup,
    ConfirmType_DeletedByGroup,
    ConfirmType_AddToGroup,
    ConfirmType_ExitGroup
};

#import <Foundation/Foundation.h>

@interface ConfirmLog : NSObject
@property (strong, nonatomic) NSString *confirmmemo, *sendercode, *sendername, *holdercode, *holdername, *groupcode, *groupname, *appcode;
@property (strong, nonatomic) NSNumber *resstate, *valid;
@property (strong, nonatomic) NSDate *resdate, *createdate;
@property (assign, nonatomic) ConfirmType confirmtype;
@end
