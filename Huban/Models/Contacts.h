//
//  Contacts.h
//  Huban
//
//  Created by sean on 15/10/14.
//  Copyright © 2015年 sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Contacts : NSObject
@property (strong, nonatomic) NSMutableArray *allContacts;
@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSArray *blockList;
@property (strong, nonatomic) NSArray *indexLetterArray;
@property (assign, nonatomic) BOOL isLoading;

- (void)configArray:(NSArray *)list;
- (NSArray *)contactInLetter:(NSString *)letter;

- (NSString *)requestPath;
- (NSDictionary *)requestParams;

- (void)resortIndexArray;
@end
