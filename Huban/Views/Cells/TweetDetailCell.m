//
//  TweetDetailCell.m
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetDetailCell_ImagePadding 4.f
#define kTweetDetailCell_HeaderWidth 36.f
#define KBottomHeight 26.f
#define KContent_Size (kScreen_Width - 3*kPaddingLeftWidth - kTweetDetailCell_HeaderWidth)
#define kTweetDetailCell_ContentFont [UIFont boldSystemFontOfSize:16.f]
#define kTweetDetailCell_TimeFont [UIFont systemFontOfSize:12.f]

#import "TweetDetailCell.h"
#import "ImageViewCCell.h"
#import "HMSegmentedControl.h"
#import "MJPhotoBrowser.h"

@interface TweetDetailCell ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UICollectionView *imagesView;
@property (strong, nonatomic) HMSegmentedControl *bottomSegmentedController;

@property (strong, nonatomic) NSMutableDictionary *imageViewDict;
@property (strong, nonatomic) NSMutableArray *sectionImages;
@end

@implementation TweetDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.clipsToBounds = YES;
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetDetailCell_HeaderWidth, kTweetDetailCell_HeaderWidth)];
            _userHeaderView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerClick)];
            [_userHeaderView addGestureRecognizer:tap];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 2*kPaddingLeftWidth, kTweetDetailCell_HeaderWidth/2)];
            _userNameLabel.font = kTweetDetailCell_ContentFont;
            _userNameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 2*kPaddingLeftWidth, kTweetDetailCell_HeaderWidth/2)];
            _timeLabel.font = kTweetDetailCell_TimeFont;
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KContent_Size, 10)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.font = kBaseFont;
            _contentLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_contentLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIentifier_TweetDetailCell_Media]) {
            _imagesView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KContent_Size, 0) collectionViewLayout:[UICollectionViewFlowLayout new]];
            _imagesView.delegate = self;
            _imagesView.dataSource = self;
            _imagesView.backgroundColor = [UIColor clearColor];
            _imagesView.scrollEnabled = NO;
            [_imagesView registerClass:[ImageViewCCell class] forCellWithReuseIdentifier:kCellIdentifier_IamgeCCell];
            [self.contentView addSubview:_imagesView];
            
            _imageViewDict = [[NSMutableDictionary alloc] init];
        }
        if (!_locationLabel) {
            _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KContent_Size, 0)];
            _locationLabel.font = kTweetDetailCell_TimeFont;
            _locationLabel.numberOfLines = 0;
            _locationLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_locationLabel];
        }
        _sectionImages = [[NSMutableArray alloc] initWithArray:@[[UIImage imageNamed:@"tweet_collection"],[UIImage imageNamed:@"tweet_report"],[UIImage imageNamed:@"tweet_unlike"],[UIImage imageNamed:@"tweet_comment"]]];
        if (!_bottomSegmentedController) {
            _bottomSegmentedController = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, KBottomHeight)];
            _bottomSegmentedController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
            _bottomSegmentedController.sectionTitles = @[@"", @"", @"" ,@""];
            _bottomSegmentedController.sectionImages = [_sectionImages copy];
            _bottomSegmentedController.verticalDividerEnabled = YES;
            _bottomSegmentedController.responseCurrentIndex = YES;
            _bottomSegmentedController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.f],
                                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x9f9f9f"]};
            _bottomSegmentedController.type = HMSegmentedControlTypeTextImages;
            _bottomSegmentedController.verticalDividerColor = [UIColor colorWithHexString:@"0xc8c7cc"];
            _bottomSegmentedController.backgroundColor = [UIColor clearColor];
            _bottomSegmentedController.verticalDividerWidth = .5f;
            [_bottomSegmentedController addLineUp:YES andDown:YES];
            [_bottomSegmentedController addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:_bottomSegmentedController];
        }
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_userHeaderView);
            make.left.equalTo(_userNameLabel);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(kTweetDetailCell_HeaderWidth);
        }];
        if (_imagesView) {
            [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_contentLabel.mas_bottom).offset(kPaddingLeftWidth);
                make.left.equalTo(_contentLabel);
                make.width.mas_equalTo(KContent_Size);
                make.height.mas_greaterThanOrEqualTo(0);
            }];
        }
        [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bottomSegmentedController.mas_top).offset(-kPaddingLeftWidth/2);
            make.left.equalTo(_contentLabel);
            make.width.height.mas_greaterThanOrEqualTo(0);
        }];
        [_bottomSegmentedController mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.locationLabel.mas_bottom).offset(kPaddingLeftWidth / 2);
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(KBottomHeight);
        }];
    }
    return self;
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    if (!_curTopic) {
        return;
    }
    //user header
    [_userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:[_curTopic owner].userlogourl] placeholderImage:[UIImage avatarPlacer]];
    
    //user name
    CGFloat userNameWidth = [[_curTopic owner].username getWidthWithFont:kTweetDetailCell_ContentFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, kTweetDetailCell_HeaderWidth/2)];
    _userNameLabel.text = [_curTopic owner].username;
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
        make.top.equalTo(_userHeaderView);
        make.width.mas_equalTo(userNameWidth);
        make.height.mas_equalTo(kTweetDetailCell_HeaderWidth/2);
    }];
    
    //time
    NSString *timeStr = [_curTopic.createdate stringTimesAgo];
    [_timeLabel fitToText:timeStr];
    
    //content
    CGFloat contentHeight = [_curTopic.topiccontent getHeightWithFont:kBaseFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
    _contentLabel.text = _curTopic.topiccontent;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
        make.top.equalTo(_timeLabel.mas_bottom).offset(kPaddingLeftWidth);
        make.height.mas_equalTo(contentHeight);
        make.width.mas_equalTo(KContent_Size);
    }];
    
    //location
    CGFloat locationHeight = [_curTopic.location getHeightWithFont:kTweetDetailCell_TimeFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
    _locationLabel.text = _curTopic.location;
    //imageView
    if (_imagesView) {
        CGFloat imageViewHeight = [TweetDetailCell heightWithMedias:[_curTopic topicMedium]];
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom);
            make.left.equalTo(_contentLabel);
            make.width.mas_equalTo(KContent_Size - 25.f); //右边距35.f - 10.f
            make.height.mas_equalTo(imageViewHeight);
        }];
        //location
        [_locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imagesView.mas_bottom).offset(kTweetDetailCell_ImagePadding);
            make.width.mas_equalTo(KContent_Size - 25.f); //右边距35.f - 10.f
            make.left.equalTo(_imagesView);
            make.height.mas_equalTo(locationHeight);
        }];
    } else {
        //location
        [_locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(kTweetDetailCell_ImagePadding);
            make.width.mas_equalTo(KContent_Size);
            make.left.equalTo(_contentLabel);
            make.height.mas_equalTo(locationHeight);
        }];
    }
    //reload data
    //reset the number of topicRelated
    _bottomSegmentedController.sectionTitles = @[@"", _curTopic.complainnum.boolValue?_curTopic.complainnum.stringValue:@"" ,
                                                 _curTopic.approvenum.boolValue?_curTopic.approvenum.stringValue:@"",
                                                 _curTopic.commentnum.boolValue?_curTopic.commentnum.stringValue:@""];
    if (_curTopic.approve.boolValue) { //点赞
        [_sectionImages replaceObjectAtIndex:2 withObject:[UIImage imageNamed:@"tweet_like"]];
    } else {
        [_sectionImages replaceObjectAtIndex:2 withObject:[UIImage imageNamed:@"tweet_unlike"]];
    }
    if (_curTopic.favorite.boolValue) { //收藏
        [_sectionImages replaceObjectAtIndex:0 withObject:[UIImage imageNamed:@"tweet_collectioned"]];
    } else {
        [_sectionImages replaceObjectAtIndex:0 withObject:[UIImage imageNamed:@"tweet_collection"]];
    }
    _bottomSegmentedController.sectionImages = _sectionImages.copy;
    [self.imagesView reloadData];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_curTopic topicMedium].count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetDetailCell_ImagePadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetDetailCell_ImagePadding;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (KContent_Size - 2*kTweetDetailCell_ImagePadding - 25.f) / 3; //右边距35.f - 10.f
    return CGSizeMake(width, width);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageViewCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier_IamgeCCell forIndexPath:indexPath];
    cell.curImageUrl = [_curTopic topicMedium][indexPath.row];
    [_imageViewDict setObject:cell.imageView forKey:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //1.获取相册
    NSMutableArray *photoArray = [NSMutableArray array];
    if (_curTopic.topicimages && ![_curTopic.topicimages isEmpty]) {
        NSArray *imageArray = [_curTopic.topicimages componentsSeparatedByString:@","];
        for (int i = 0;i < imageArray.count;i ++) {
            MJPhoto *photo = [[MJPhoto alloc] init];
            NSString *subPath = imageArray[i];
            NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            photo.srcImageView = [_imageViewDict objectForKey:curIndexPath];
            photo.url = [NSURL imageURLWithString:subPath];
            [photoArray addObject:photo];
        }
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.showSaveBtn = NO;
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photoArray; // 设置所有的图片
    [browser show];
}

#pragma mark - Private Method
+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat rowHeight = 0;
    
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)obj;
        
        //headerView
        rowHeight += kPaddingLeftWidth;
        rowHeight += kTweetDetailCell_HeaderWidth;
        rowHeight += kPaddingLeftWidth;
        
        //content
        CGFloat contentHeight = [curTopic.topiccontent getHeightWithFont:kBaseFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
        rowHeight += contentHeight;
        
        //imageView
        if (curTopic.topicMedium.count > 0) {
            CGFloat imageViewHieght = [TweetDetailCell heightWithMedias:[curTopic topicMedium]];
            rowHeight += imageViewHieght;
        }
        rowHeight += kTweetDetailCell_ImagePadding;

        //location
        if (curTopic.location && ![curTopic.location isEmpty]) {
            CGFloat locationHeight = [curTopic.location getHeightWithFont:kTweetDetailCell_TimeFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
            rowHeight += locationHeight;
        }
        
        //bottom
        rowHeight += kTweetDetailCell_ImagePadding;
        rowHeight += KBottomHeight;
        rowHeight += kTweetDetailCell_ImagePadding;
    }
    
    return rowHeight;
}

+ (CGFloat)heightWithMedias:(NSArray *)medias {
    CGFloat CHeight = 0;
    CGFloat height = (KContent_Size - 2*kTweetDetailCell_ImagePadding - 25.f) / 3;
    NSInteger row = ceilf(medias.count / 3.f);
    CHeight = height * row;
    return CHeight;
}

#pragma mark - Action
- (void)headerClick {
    if (_headerClickedBlock) {
        _headerClickedBlock([_curTopic owner]);
    }
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
        }
            break;
        case 1: {
            if (_curTopic.complainnum.boolValue) {
                kTipAlert(@"已举报,等待后台处理");
                return;
            }
        }
            break;
        default:
            break;
    }
    if (_segmentedControlBlock) {
        _segmentedControlBlock(segmentedControl.selectedSegmentIndex, _curTopic);
    }
}
@end
