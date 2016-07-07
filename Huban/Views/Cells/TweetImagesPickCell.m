//
//  TweetImagesPickCell.m
//  Huban
//
//  Created by sean on 15/9/1.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kCellItemWidth ((kScreen_Width - 2*kPaddingLeftWidth - 3*kCell_CellMargin)/4.f)
#define Kcell_OneLineHeight 80.f
#define kCell_CellMargin 12.f
#define kCell_ContentMargin 7.f

#import "TweetImagesPickCell.h"
#import "ImageViewCCell.h"

@interface TweetImagesPickCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *myCollectionView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;
@end

@implementation TweetImagesPickCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_myCollectionView) {
            _myCollectionView = ({
               UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
                collectionView.delegate = self;
                collectionView.dataSource = self;
                collectionView.backgroundColor = [UIColor clearColor];
                collectionView.contentInset = UIEdgeInsetsMake(kCell_ContentMargin, kPaddingLeftWidth, kCell_ContentMargin, kPaddingLeftWidth);
                [collectionView registerClass:[ImageViewCCell class] forCellWithReuseIdentifier:kCellIdentifier_IamgeCCell];
                [self.contentView addSubview:collectionView];
                [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.contentView);
                }];
                collectionView;
            });
        }
        if (!_imageViewsDict) {
            _imageViewsDict = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    [self.myCollectionView reloadData];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger num = _curTopic.topicImageArray.count;
    return num < 9?num + 1:num;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kCellItemWidth, kCellItemWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kCell_CellMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kCell_CellMargin;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_IamgeCCell forIndexPath:indexPath];
    if (indexPath.row < _curTopic.topicImageArray.count) {
        TopicImage *curImage = [self.curTopic.topicImageArray objectAtIndex:indexPath.row];
        cell.curTopicImage = curImage;
    } else {
        cell.curImage = [UIImage imageNamed:@"tweetImage"];
    }
    [_imageViewsDict setObject:cell.imageView forKey:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _curTopic.topicImageArray.count) {
        if (_addPhotoBlock) {
            _addPhotoBlock();
        }
    } else {
        if (_photoSelectedBlock) {
            _photoSelectedBlock(indexPath.row, _imageViewsDict);
        }
    }
}

#pragma mark - Priavte
+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat cellHeight = kCellItemWidth + 2*kCell_ContentMargin;
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)obj;
        if (curTopic.topicImageArray && curTopic.topicImageArray.count > 0) {
            NSInteger itemCount = curTopic.topicImageArray.count < 9?curTopic.topicImageArray.count + 1:curTopic.topicImageArray.count;
            CGFloat num = ceil(itemCount/4.f);
            cellHeight = kCell_ContentMargin*2 + (num * kCellItemWidth) + ((num - 1) * kCell_CellMargin);
        }
    }
    return cellHeight;
}

@end
