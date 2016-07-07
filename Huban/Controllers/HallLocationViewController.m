//
//  HallChattingViewController.m
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "HallLocationViewController.h"
#import "HMSegmentedControl.h"
#import "TitleDisclosureCell.h"
#import "HallChatViewController.h"

@interface HallLocationViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *locationArray;
@property (strong, nonatomic) NSMutableArray *indexTitleArray;
@property (assign, nonatomic) NSInteger currentLocationIndex;
@end

@implementation HallLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"候厅热聊";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [tableView registerClass:[TitleDisclosureCell class] forCellReuseIdentifier:kCellIdentifier_TitleDisclosure];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    _myTableView.tableHeaderView = [self customerHeader];
    [self setupData];
}

- (void)setupData {
    if (!_indexTitleArray) {
        _indexTitleArray = [NSMutableArray array];
    } else {
        [_indexTitleArray removeAllObjects];
    }
    for (int i = 65; i <= 90; i++) {
        NSString *charStr = [NSString stringWithFormat:@"%c",i];
        [_indexTitleArray addObject:charStr];
    }
    
    if (!_locationArray) {
        _locationArray = [[NSMutableArray alloc] init];
    } else {
        [_locationArray removeAllObjects];
    }
    for (NSString *indexTitle in _indexTitleArray) {
        if (_currentLocationIndex == 0) {
//            HallLocation *location = [[HallLocation alloc] init];
//            location.location = @"武汉天河飞机场";
//            [_locationArray addObject:@{indexTitle:@[location]}];
        } else if (_currentLocationIndex == 1) {
//            HallLocation *location = [[HallLocation alloc] init];
//            location.location = @"武汉汉口火车站";
//            [_locationArray addObject:@{indexTitle:@[location]}];
        } else if (_currentLocationIndex == 2) {
//            HallLocation *location = [[HallLocation alloc] init];
//            location.location = @"武汉宏碁汽车站";
//            [_locationArray addObject:@{indexTitle:@[location]}];
        }
    }
}

- (NSString *)indexTitleForSection:(NSInteger)section {
    NSDictionary *dic = _locationArray[section];
    return dic.allKeys.firstObject;
}

- (NSArray *)dataForSection:(NSInteger)section {
    NSString *keyStr = [self indexTitleForSection:section];
    NSDictionary *dict = _locationArray[section];
    return dict[keyStr];
}

- (UIView *)customerHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44.f)];
    [header addLineLeft:NO andRight:YES];
    header.backgroundColor = [UIColor clearColor];
    
    HMSegmentedControl *locationSegmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, CGRectGetHeight(header.frame))];
    locationSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    locationSegmentedControl.selectionIndicatorHeight = 1.5f;
    locationSegmentedControl.selectionIndicatorColor = SYSBACKGROUNDCOLOR_BLUE;
    locationSegmentedControl.sectionTitles = @[@"飞机场", @"火车站", @"汽车站"];
    locationSegmentedControl.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.f],
                                                       NSForegroundColorAttributeName:SYSFONTCOLOR_BLACK};
    locationSegmentedControl.selectedTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.f],
                                                             NSForegroundColorAttributeName:SYSBACKGROUNDCOLOR_BLUE};
    locationSegmentedControl.type = HMSegmentedControlTypeText;
    locationSegmentedControl.borderType = HMSegmentedControlBorderTypeBottom;
    locationSegmentedControl.borderWidth = .5f;
    locationSegmentedControl.borderColor = [UIColor colorWithHexString:@"0xc8c7cc"];
    [locationSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [header addSubview:locationSegmentedControl];
    
    return header;
}

#pragma makr - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _locationArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self dataForSection:section].count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexTitleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _indexTitleArray[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TitleDisclosureCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TitleDisclosureCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TitleDisclosure forIndexPath:indexPath];
//    HallLocation *curLocation = [self dataForSection:indexPath.section][indexPath.row];
//    [cell setTitleStr:curLocation.location];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HallChatViewController *chatViewController = [[HallChatViewController alloc] init];
//    HallLocation *curLocation = [self dataForSection:indexPath.section][indexPath.row];
//    chatViewController.curHallLocation = curLocation;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark - Action
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    _currentLocationIndex = segmentedControl.selectedSegmentIndex;
    [self setupData];
    [self.myTableView reloadData];
}
@end
