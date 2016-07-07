//
//  TweetLikesCell.m
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetLikesCell_MarginTop 3.f
#define kTweetLikesCell_CellSpacing 6.f
#define kTweetLikesButton_Width 16.f
#define kTweetLikesCell_ContentWidth (kScreen_Width - 4*kPaddingLeftWidth - kTweetLikesButton_Width)
#define kTweetLikesCell_NumberOfOneLine 8.f
#define kTweetDetailCell_LikeNumMax 16

#import "TweetLikesCell.h"
#import "TweetLikeUserCell.h"
#import "TopicLike.h"

@interface TweetLikesCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIButton *likeButton;
@property (strong, nonatomic) UICollectionView *myCollectionView;
@end

@implementation TweetLikesCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_likeButton) {
            _likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [_likeButton setImage:[UIImage imageNamed:@"tweet_unlike"] forState:UIControlStateNormal];
            [_likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_likeButton];
        }
        if (!_myCollectionView) {
            _myCollectionView = ({
                UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kTweetLikesCell_ContentWidth, 0) collectionViewLayout:[UICollectionViewFlowLayout new]];
                collectionView.delegate = self;
                collectionView.dataSource = self;
                collectionView.backgroundColor = [UIColor clearColor];
                collectionView.contentInset = UIEdgeInsetsMake(kTweetLikesCell_MarginTop, 0, kTweetLikesCell_MarginTop, 0);
                [collectionView registerClass:[TweetLikeUserCell class] forCellWithReuseIdentifier:kCellIdentifier_TweetLikeUserCell];
                [self.contentView addSubview:collectionView];
                collectionView;
            });
        }
        [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(2*kPaddingLeftWidth);
            make.top.mas_equalTo((36.f-kTweetLikesButton_Width)/2);
            make.width.height.mas_equalTo(kTweetLikesButton_Width);
        }];
        [_myCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_likeButton.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kTweetLikesCell_MarginTop);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    if (!_curTopic) {
        return;
    }
    [_myCollectionView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat cellHeight = 36.f;
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)obj;
        if (curTopic.likes_users.count > 0) {
            NSInteger row = ceil(curTopic.likes_users.count / kTweetLikesCell_NumberOfOneLine);
            row = MIN(row, 2);
            if (row > 1) {
                CGFloat cellWidth = floor((kTweetLikesCell_ContentWidth - (kTweetLikesCell_NumberOfOneLine - 1)*kTweetLikesCell_CellSpacing) / kTweetLikesCell_NumberOfOneLine);
                cellHeight = kTweetLikesCell_MarginTop*3 + cellWidth*row + kTweetLikesCell_MarginTop*(row - 1);
            }
        }
    }
    return cellHeight;
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CGFloat rectWidth = rect.size.width;
    CGFloat rectHeight = rect.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xECECEC"].CGColor);
    
    CGContextMoveToPoint(context, kPaddingLeftWidth, kTweetLikesCell_MarginTop);
    //draw the indicator
    CGContextAddLineToPoint(context, kPaddingLeftWidth + 2*kTweetLikesCell_MarginTop, kTweetLikesCell_MarginTop);
    CGContextAddLineToPoint(context, kPaddingLeftWidth + 3*kTweetLikesCell_MarginTop, 0);
    CGContextAddLineToPoint(context, kPaddingLeftWidth + 4*kTweetLikesCell_MarginTop, kTweetLikesCell_MarginTop);
    
    //close the frame
    CGContextAddLineToPoint(context, rectWidth - kPaddingLeftWidth, kTweetLikesCell_MarginTop);
    CGContextAddLineToPoint(context, rectWidth - kPaddingLeftWidth, rectHeight);
    CGContextAddLineToPoint(context, kPaddingLeftWidth, rectHeight);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Action
- (void)likeButtonClicked:(id)sender {
    NSLog(@"点击");
}

#pragma mark - ColletionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _curTopic.numbOfLikers;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetLikesCell_CellSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetLikesCell_MarginTop;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = floor((kTweetLikesCell_ContentWidth - (kTweetLikesCell_NumberOfOneLine - 1)*kTweetLikesCell_CellSpacing) / kTweetLikesCell_NumberOfOneLine);
    return CGSizeMake(cellWidth, cellWidth);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TweetLikeUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_TweetLikeUserCell forIndexPath:indexPath];
    if (indexPath.row >= _curTopic.numbOfLikers - 1 && _curTopic.hasMoreLikers) {
        [cell configWithUser:nil likesNum:_curTopic.approvenum];
    } else {
        if (_curTopic.likes_users.count > indexPath.row) {
           TopicLike *curUser = _curTopic.likes_users[indexPath.row];
            [cell configWithUser:curUser likesNum:nil];
        } else {
            [cell configWithUser:nil likesNum:_curTopic.approvenum];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _curTopic.numbOfLikers - 1 && _curTopic.hasMoreLikers) {
        if (_showMoreLikerBlock) {
            _showMoreLikerBlock(_curTopic);
        }
    } else {
        TopicLike *curUser = _curTopic.likes_users[indexPath.row];
        if (_userClickedBlock) {
            _userClickedBlock(curUser);
        }
    }
}
@end
