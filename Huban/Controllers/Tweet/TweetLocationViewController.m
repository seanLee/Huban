//
//  TweetLocationViewController.m
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TweetLocationViewController.h"
#import "TweetLocationCell.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface TweetLocationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *locationArray;
@end

@implementation TweetLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"所在位置";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetLocationCell class] forCellReuseIdentifier:kCellIdentifier_TweetLocationCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    //定位当前坐标
    @weakify(self);
    [[LocationManager shareInstance] getLocationWithBlock:^(BMKUserLocation *userLocation) {
        @strongify(self);
        [[NetAPIManager shareManager] request_locationWithLat:userLocation.location.coordinate.latitude andLon:userLocation.location.coordinate.longitude andBlock:^(id data, NSError *error) {
            if (data) {
                NSLog(@"%@",data);
            }
        }];
    }];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _locationArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TweetLocationCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetLocationCell forIndexPath:indexPath];
    [cell setTextStr:_locationArray[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetLocationCell *curCell = (TweetLocationCell *)[tableView cellForRowAtIndexPath:indexPath];
    curCell.showCheckmark = !curCell.showCheckmark;
}

@end
