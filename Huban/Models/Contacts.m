//
//  Contacts.m
//  Huban
//
//  Created by sean on 15/10/14.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Contacts.h"

@interface Contacts ()
@property (strong, nonatomic) NSMutableArray *priIndexArray;
@end

@implementation Contacts
- (void)configArray:(NSArray *)list {
    if (self.allContacts.count > 0) {
        [self.allContacts removeAllObjects];
    }
    [_allContacts addObjectsFromArray:list];
}

- (NSArray *)contactInLetter:(NSString *)letter {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"contactletter == %@", letter];
    NSArray *result = [_allContacts filteredArrayUsingPredicate:predicate];
    return result;
}

- (NSString *)requestPath {
    return @"router";
}
- (NSDictionary *)requestParams {
    return @{@"method":@"user.contact.pagerbyholder",@"holdercode":[[Login curLoginUser] usercode]
             ,@"start":@0,@"limit":@0}; //都传0的时候,则不分页
}

#pragma mark - Getter and Setter
- (NSMutableArray *)allContacts {
    if (!_allContacts) {
        _allContacts = [[NSMutableArray alloc] init];
    }
    return _allContacts;
}

- (NSMutableArray *)priIndexArray {
    if (!_priIndexArray) {
        _priIndexArray = [[NSMutableArray alloc] init];
    }
    return _priIndexArray;
}

- (NSArray *)indexLetterArray {
    if (!_indexLetterArray) {
        [self sortIndexArray];
        [self sortPublictIndexArray];
    }
    return _indexLetterArray;
}

#pragma mark - Private Method
- (void)sortIndexArray {
    for (Contact *contact in _allContacts) {
        if ([self.priIndexArray containsObject:contact.contactletter]) {
            continue;
        }
        [self.priIndexArray addObject:contact.contactletter];
    }
}

- (void)sortPublictIndexArray {
    _indexLetterArray = [_priIndexArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];;
}

- (void)resortIndexArray {
    [self.priIndexArray removeAllObjects];
    [self sortIndexArray];
    [self sortPublictIndexArray];
}
@end
