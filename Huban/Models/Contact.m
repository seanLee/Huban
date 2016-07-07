//
//  Contact.m
//  Huban
//
//  Created by sean on 15/10/9.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Contact.h"

@implementation Contact
- (NSString *)toPath {
    return @"router";
}

- (NSDictionary *)addedParams {
    return @{@"method":@"user.contact.create",@"holdercode":_holdercode,@"contactcode":_contactcode,
             @"confirmmemo":_confirmmemo};
}
- (NSDictionary *)deletedParams {
    return @{@"method":@"user.contact.delete",@"holdercode":_holdercode,@"contactcode":_contactcode};
}
- (NSDictionary *)blockParams {
    return @{@"method":@"user.contact.chgblocked",@"holdercode":_holdercode,@"contactcode":_contactcode,@"blocked":_blocked};
}
- (NSDictionary *)changeMemoParams {
    return @{@"method":@"user.contact.chgmemo",@"holdercode":_holdercode,@"contactcode":_contactcode,@"contactmemo":_contactmemo.length == 0?@"":_contactmemo};
}
- (NSDictionary *)changeSpamshieldParams {
    return @{@"method":@"user.contact.chgspamshield",@"holdercode":_holdercode,@"contactcode":_contactcode,@"spamshield":_spamshield};
}
@end
