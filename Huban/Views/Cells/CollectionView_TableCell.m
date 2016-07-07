//
//  CollectionView_TableCell.m
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "CollectionView_TableCell.h"

@interface CollectionView_TableCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *myColleciontView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageArray;
@end

@implementation CollectionView_TableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_myColleciontView) {
            _myColleciontView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[UICollectionViewFlowLayout new]];
            _myColleciontView.backgroundColor = [UIColor whiteColor];
            _myColleciontView.delegate = self;
            _myColleciontView.dataSource = self;
            [_myColleciontView registerClass:[AddUserTypeCCell class] forCellWithReuseIdentifier:kCellIdentifier_AddUserTypeCCell];
            [self.contentView addSubview:_myColleciontView];
        }
        [_myColleciontView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _titleArray = @[@"添加手机联系人",@"添加微信好友",@"添加QQ好友"];
        _imageArray = @[@"contactBook_add_phone",@"contactBook_add_wechat",@"contactBook_add_qq"];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 98.f;
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat width = floor(kScreen_Width/3.f);
    return (kScreen_Width - 3*width)/2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor(kScreen_Width/3.f);
    return CGSizeMake(width, [[self class] cellHeight]);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AddUserTypeCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_AddUserTypeCCell forIndexPath:indexPath];
    if (indexPath.row % 3 != 2) {
        [cell addLineLeft:NO andRight:YES];
    }
    [cell addLineUp:YES andDown:YES];
    [cell setTextStr:_titleArray[indexPath.row] andIcon:_imageArray[indexPath.row]];
    return cell;
}
@end

#define kAddUserTypeCCell_IconWidth 27.f
#define kAddUserTypeCCell_LabelHeight 18.f
#define kAddUserTypeCCell_MariginTop 26.f
#define kAddUserTypeCCell_LabelMarginTop 13.f

@interface AddUserTypeCCell ()
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *textLabel;
@end

@implementation AddUserTypeCCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (!_iconImageView) {
            _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddUserTypeCCell_IconWidth, kAddUserTypeCCell_IconWidth)];
            [self.contentView addSubview:_iconImageView];
        }
        if (!_textLabel) {
            _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kAddUserTypeCCell_LabelHeight)];
            _textLabel.textColor = SYSFONTCOLOR_BLACK;
            _textLabel.textAlignment = NSTextAlignmentCenter;
            _textLabel.font = [UIFont systemFontOfSize:12.f];
            [self.contentView addSubview:_textLabel];
        }
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kAddUserTypeCCell_MariginTop);
            make.centerX.equalTo(self.mas_centerX);
            make.width.mas_equalTo(kAddUserTypeCCell_IconWidth);
            make.height.mas_equalTo(kAddUserTypeCCell_IconWidth + 1);
        }];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_iconImageView.mas_bottom).offset(kAddUserTypeCCell_LabelMarginTop);
            make.left.right.equalTo(self);
            make.height.mas_equalTo(kAddUserTypeCCell_LabelHeight);
        }];
    }
    return self;
}

- (void)setTextStr:(NSString *)str andIcon:(NSString *)imageStr {
    if (str) {
        _textLabel.text = str;
    }
    if (imageStr) {
        _iconImageView.image = [UIImage imageNamed:imageStr];
    }
}
@end
