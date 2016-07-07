//
//  UserAlbumCell.m
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kUserAlbumCell_LabelWidth 70.f
#define kUserAlbumCell_ImageWidth 64.f
#define kUserAlbumCell_MariginRight 44.f
#define kUserAlbumCell_ItemPadding 4.f
#define kUserAlbumCell_IndicatorViewWidth 10.f
#define kUserAlbumCell_IndicatorViewMarginRight 12.f

#import "UserAlbumCell.h"
#import "ImageViewCCell.h"

@interface UserAlbumCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UICollectionView *myCollectionView;
@property (strong, nonatomic) UIView *indicatorView;
@end

@implementation UserAlbumCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, kUserAlbumCell_LabelWidth, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:14.f];
            _titleLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_titleLabel];
        }
        if (!_indicatorView) {
            _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
            [self drawIndicator];
            [self.contentView addSubview:_indicatorView];
        }
        if (!_myCollectionView) {
            _myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
            _myCollectionView.delegate = self;
            _myCollectionView.dataSource = self;
            _myCollectionView.backgroundColor = [UIColor whiteColor];
            [_myCollectionView registerClass:[ImageViewCCell class] forCellWithReuseIdentifier:kCellIdentifier_IamgeCCell];
            [self.contentView addSubview:_myCollectionView];
        }
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(kUserAlbumCell_LabelWidth);
            make.height.mas_equalTo([UserAlbumCell cellHeight]);
        }];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            make.width.mas_equalTo(kUserAlbumCell_IndicatorViewWidth);
            make.right.equalTo(self.contentView).offset(-kUserAlbumCell_IndicatorViewMarginRight);
        }];
        [_myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(_indicatorView.mas_left).offset(-kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        
    }
    return self;
}

- (void)setDataItems:(NSArray *)dataItems {
    _dataItems = dataItems;
    if (!_dataItems || _dataItems.count == 0) {
        return;
    }
    [self.myCollectionView reloadData];
}

- (void)setTitleStr:(NSString *)title {
    _titleLabel.text = title;
}

+ (CGFloat)cellHeight {
    return 88.f;
}

#pragma mark - Draw
- (void)drawIndicator {
    CGFloat width = 6.f;
    CGFloat height = 12.f;
    
    UIBezierPath *indicatorPath = [[UIBezierPath alloc] init];
    [indicatorPath moveToPoint:CGPointMake(0, 0)];
    [indicatorPath addLineToPoint:CGPointMake(width, height/2)];
    [indicatorPath addLineToPoint:CGPointMake(0, height)];
    
    CAShapeLayer *indicatorLayer = [CAShapeLayer layer];
    indicatorLayer.strokeColor = [UIColor colorWithWhite:0 alpha:.2f].CGColor;
    indicatorLayer.lineWidth = 1.8f;
    indicatorLayer.fillColor = [UIColor clearColor].CGColor;
    indicatorLayer.path = indicatorPath.CGPath;
    indicatorLayer.position = CGPointMake(0, ([UserAlbumCell cellHeight] - height)/2);
    
    [_indicatorView.layer addSublayer:indicatorLayer];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat imageWidth = floor((kScreen_Width - kUserAlbumCell_IndicatorViewMarginRight - kUserAlbumCell_IndicatorViewWidth - 3*kPaddingLeftWidth - kUserAlbumCell_LabelWidth - 2*kUserAlbumCell_ItemPadding)/3.f);
    return CGSizeMake(imageWidth, imageWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kUserAlbumCell_ItemPadding;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat imageWidth = floor((kScreen_Width - kUserAlbumCell_IndicatorViewMarginRight - kUserAlbumCell_IndicatorViewWidth - 3*kPaddingLeftWidth - kUserAlbumCell_LabelWidth - 2*kUserAlbumCell_ItemPadding)/3.f);
    CGFloat marigin = ([UserAlbumCell cellHeight] - 2*kPaddingLeftWidth - imageWidth)/2;
    return UIEdgeInsetsMake(marigin, 0, marigin, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_IamgeCCell forIndexPath:indexPath];
    NSString *subUrl = _dataItems[indexPath.row];
    if (subUrl && ![subUrl isEmpty]) {
         [cell setCurImageUrl:[NSURL thumbImageURLWithString:subUrl]];
    }
    return cell;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}
@end
