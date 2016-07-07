//
//  CityChosenCell.m
//  Huban
//
//  Created by sean on 15/8/28.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCityChosenCell_HeightForOneLine 44.f
#define kCityChosenCell_IndicatorWidth 8.f
#define kCityChosenCell_IndicatorHeight 10.f
#define kCityChosenCell_CPadingRight 32.f
#define kCityChosenCell_CMarginTop 7.f
#define kCityChosenCell_ItemHeight 27.f

#import "CityChosenCell.h"
#import "LabelCCell.h"

@interface CityChosenCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UILabel *groupTitleLabel;
@property (strong, nonatomic) UICollectionView *myCollectionView;

@property (strong, nonatomic) CAShapeLayer *triangleLayer;

@property (assign, nonatomic) BOOL hasDropDown;
@end

@implementation CityChosenCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_titleView) {
            _titleView = [[UIView alloc] initWithFrame:CGRectZero];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [_titleView addGestureRecognizer:tap];
            _titleView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_titleView];
        }
        if (!_indicatorView) {
            _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
            _indicatorView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
            [_titleView addSubview:_indicatorView];
        }
        if (!_groupTitleLabel) {
            _groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _groupTitleLabel.font = [UIFont systemFontOfSize:14.f];
            _groupTitleLabel.textColor = SYSFONTCOLOR_BLACK;
            _groupTitleLabel.textAlignment = NSTextAlignmentLeft;
            [_titleView addSubview:_groupTitleLabel];
        }
        if (!_myCollectionView) {
            _myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
            _myCollectionView.delegate = self;
            _myCollectionView.dataSource = self;
            _myCollectionView.backgroundColor = [UIColor clearColor];
            _myCollectionView.contentInset = UIEdgeInsetsMake(0, kPaddingLeftWidth, kPaddingLeftWidth, kPaddingLeftWidth);
            [_myCollectionView registerClass:[LabelCCell class] forCellWithReuseIdentifier:kCellIdentifier_LabelCCell];
            [self.contentView addSubview:_myCollectionView];
        }
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(kCityChosenCell_HeightForOneLine);
        }];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(_titleView);
            make.width.height.mas_equalTo(kCityChosenCell_IndicatorHeight);
        }];
        [_groupTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_indicatorView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(_titleView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(_titleView);
            make.height.mas_equalTo(kCityChosenCell_HeightForOneLine);
        }];
        [_myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleView.mas_bottom);
            make.bottom.equalTo(self.contentView);
            make.left.right.equalTo(self.contentView);
        }];
        if (!_triangleLayer) {
            [self addIndicatorLayer];
        }
    }
    return self;
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _showIndicator = showIndicator;
    if (_showIndicator) {
        _indicatorView.backgroundColor = [UIColor lightGrayColor];
    } else {
        _indicatorView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setGroupTitleStr:(NSString *)title {
    _groupTitleLabel.text = title;
}

- (void)checkState:(BOOL)state {
    _hasDropDown = state;
    [self checkoutState];
}

+ (CGFloat)cellHeightWithDataItms:(NSArray *)dataItems andDropList:(BOOL)showDropDown {
    CGFloat cellHeight = 0;
    NSInteger row = ceil(dataItems.count/3.f);
    if (showDropDown) {
        if (row > 0) {
            cellHeight = kCityChosenCell_HeightForOneLine + row*kCityChosenCell_ItemHeight + (row-1)*kCityChosenCell_CMarginTop + kPaddingLeftWidth;
        } else {
            cellHeight = kCityChosenCell_HeightForOneLine;
        }
    } else {
        cellHeight = kCityChosenCell_HeightForOneLine;
    }
    return cellHeight;
}

- (void)setDataItems:(NSArray *)dataItems {
    _dataItems = dataItems;
    if (!_dataItems || _dataItems.count == 0) {
        return;
    }
    [self.myCollectionView reloadData];
}

#pragma mark - Draw
- (void)addIndicatorLayer {
    UIBezierPath *trianglePath = [[UIBezierPath alloc] init];
    [trianglePath moveToPoint:CGPointMake(0, 0)];
    [trianglePath addLineToPoint:CGPointMake(kCityChosenCell_IndicatorWidth, kCityChosenCell_IndicatorHeight/2)];
    [trianglePath addLineToPoint:CGPointMake(0, kCityChosenCell_IndicatorHeight)];
    [trianglePath closePath];
    
    _triangleLayer = [CAShapeLayer layer];
    _triangleLayer.path = trianglePath.CGPath;
    
    [_indicatorView.layer setMask:_triangleLayer];
}

#pragma mark - Action
- (void)handleTap:(UIGestureRecognizer *)recognizer {
    _hasDropDown = !_hasDropDown;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        [weakSelf checkoutState];
    } completion:^(BOOL finished) {
        if (_groupTitleTapBlock) {
            _groupTitleTapBlock(_hasDropDown);
        }
    }];
}

#pragma mark - Private Method
- (void)checkoutState {
    if (_hasDropDown) {
        _indicatorView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    } else {
        _indicatorView.layer.transform = CATransform3DIdentity;
    }
}

#pragma mark - ColletionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = (kScreen_Width - 2*kPaddingLeftWidth - 2*kCityChosenCell_CPadingRight)/3;
    return CGSizeMake(itemWidth, kCityChosenCell_ItemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCityChosenCell_CPadingRight;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCityChosenCell_CMarginTop;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LabelCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_LabelCCell forIndexPath:indexPath];
    if (_dataItems && indexPath.row < _dataItems.count) {
        Region *curRegion = _dataItems[indexPath.row];
        cell.textStr = curRegion.cityname;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_itemClickedBlock) {
        _itemClickedBlock(_dataItems[indexPath.row]);
    }
}

@end
