//
//  UIMessageInputView_Add.m
//  Coding_iOS
//
//  Created by Ease on 15/4/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "UIMessageInputView_Add.h"

@interface UIMessageInputView_Add () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *myCollectionView;
@property (strong, nonatomic) NSArray *dataItems;
@end

@implementation UIMessageInputView_Add
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        
        _myCollectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.backgroundColor = [UIColor clearColor];
            [collectionView registerClass:[UIMessageInputView_Add_CCell class] forCellWithReuseIdentifier:kCellIdentifier_UIMessageInputView_Add_CCell];
            [self addSubview:collectionView];
            collectionView;
        });
        
        _dataItems = @[@[@"图片",@"function_image"]
                       ,@[@"位置",@"function_location"]
//                       ,@[@"语音聊天",@"function_voiceChat"]
                       ];
    }
    return self;
}

- (NSArray *)dataForRow:(NSInteger)row {
    return _dataItems[row];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataItems.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [UIMessageInputView_Add_CCell cellSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIMessageInputView_Add_CCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_UIMessageInputView_Add_CCell forIndexPath:indexPath];
    NSArray *curItem = [self dataForRow:indexPath.row];
    [cell setTextStr:curItem.firstObject andIconStr:curItem.lastObject];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_addIndexBlock) {
        _addIndexBlock(indexPath.row);
    }
}
@end

#define kUIMessageInputView_Add_CCell_ImageWidth 50.f

@interface UIMessageInputView_Add_CCell ()
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) UILabel *textL;
@end

@implementation UIMessageInputView_Add_CCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_iconImgView) {
            _iconImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:_iconImgView];
        }
        if (!_textL) {
            _textL = [[UILabel alloc] initWithFrame:CGRectZero];
            _textL.font = [UIFont systemFontOfSize:12.f];
            _textL.textColor = [UIColor lightGrayColor];
            _textL.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_textL];
        }
        [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kUIMessageInputView_Add_CCell_ImageWidth);
            make.center.equalTo(self.contentView);
        }];
        [_textL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImgView.mas_bottom).offset(6.f);
            make.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setTextStr:(NSString *)textStr andIconStr:(NSString *)iconStr {
    _textL.text = textStr;
    _iconImgView.image = [UIImage imageNamed:iconStr];
}

+ (CGSize)cellSize {
   return CGSizeMake(kScreen_Width/4.f, 216/2.f); //高度为更多页的一半
}
@end
