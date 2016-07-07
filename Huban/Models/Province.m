//
//  Province.m
//  Huban
//
//  Created by sean on 15/11/18.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "Province.h"

@implementation Province
- (NSMutableArray *)subRegionArray {
    if (!_subRegionArray) {
        _subRegionArray = [[NSMutableArray alloc] initWithArray:[[DataBaseManager shareInstance] regionListForProvince:self.provcode]];
    }
    return _subRegionArray;
}
@end
