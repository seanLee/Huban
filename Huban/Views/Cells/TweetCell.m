//
//  TweetCell.m
//  Huban
//
//  Created by sean on 15/8/1.
//  Copyright (c) 2015年 sean. All rights reserved.
//
#define kTweetCell_ImagePadding 4.f
#define kTweetCell_TitlePadding 2.f
#define kTweetCell_HeaderWidth 36.f
#define kTweetCell_PaddingRight 35.f
#define kTweetCell_GenderIconWidth 20.f
#define kTweetCell_MoreDetailButtonHeight 20.f
#define kTweetCell_LevelSize CGSizeMake(42.f, 16.f)
#define kTweetCell_ActionButtonSize CGSizeMake(50.f, 18.f)
#define kTweetCell_CrownWidth 21.f
#define kTweetCell_CrownHeight 19.f
#define KBottomHeight 26.f
#define KContent_Size (kScreen_Width - 3*kPaddingLeftWidth - kTweetCell_HeaderWidth)
#define kTweetCell_NameFont [UIFont boldSystemFontOfSize:15.f]
#define kTweetCell_ContentFont [UIFont systemFontOfSize:15.f]
//#define kTweetCell_TimeFont [UIFont systemFontOfSize:12.f]
#define kTweetCell_MaxContentHeight 94.f //计算所得

#import "TweetCell.h"
#import "HMSegmentedControl.h"
#import "ImageViewCCell.h"
#import "UITTTAttributedLabel.h"
#import "MJPhotoBrowser.h"

@interface TweetCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UILabel *locationLabel;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) UICollectionView *imagesView;
@property (strong ,nonatomic) UIImageView *genderIconView;
@property (strong, nonatomic) UIImageView *crownView;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIButton *moreDetailButton;
@property (strong, nonatomic) HMSegmentedControl *bottomSegmentedController;

@property (strong, nonatomic) UIMenuController *menuController;

@property (assign, nonatomic) BOOL showMoreDetailButton;
@property (assign, nonatomic) BOOL showFullContentDetail;

@property (strong, nonatomic) NSMutableDictionary *imageViewDict;
@property (strong, nonatomic) NSMutableArray *sectionImages;
@end

@implementation TweetCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_HeaderWidth, kTweetCell_HeaderWidth)];
            _userHeaderView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [_userHeaderView addGestureRecognizer:tap];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 2*kPaddingLeftWidth, kTweetCell_HeaderWidth/2)];
            _userNameLabel.font = kTweetCell_NameFont;
            _userNameLabel.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_genderIconView) {
            _genderIconView = [[UIImageView alloc] init];
            [self.contentView addSubview:_genderIconView];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width - 2*kPaddingLeftWidth, kTweetCell_HeaderWidth/2)];
            _timeLabel.font = kBaseFont;
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, KContent_Size, 10)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.font = kTweetCell_ContentFont;
            _contentLabel.textColor = SYSFONTCOLOR_BLACK;
            [_contentLabel addLongPressForCopy];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_moreDetailButton) {
            _moreDetailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, kTweetCell_MoreDetailButtonHeight)];
            _moreDetailButton.titleLabel.font = kBaseFont;
            _moreDetailButton.hidden = YES;
            [_moreDetailButton setTitle:@"更多" forState:UIControlStateNormal];
            [_moreDetailButton setTitle:@"收起" forState:UIControlStateSelected];
            [_moreDetailButton setTitleColor:SYSBACKGROUNDCOLOR_BLUE forState:UIControlStateNormal];
            [_moreDetailButton sizeToFit];
            [_moreDetailButton addTarget:self action:@selector(showMoreDetailClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_moreDetailButton];
        }
        if ([reuseIdentifier isEqualToString:kCellIentifier_TweetCell_Media]) {
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
            _locationLabel.font = kBaseFont;
            _locationLabel.numberOfLines = 0;
            _locationLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_locationLabel];
        }
        if (!_levelLabel) {
            _levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_LevelSize.width, kTweetCell_LevelSize.height)];
            _levelLabel.font = [UIFont boldSystemFontOfSize:13.f];
            _levelLabel.textAlignment = NSTextAlignmentCenter;
            _levelLabel.textColor = [UIColor whiteColor];
            _levelLabel.layer.cornerRadius = 2.f;
            _levelLabel.layer.masksToBounds = YES;
            [self.contentView addSubview:_levelLabel];
        }
        if (!_crownView) {
            _crownView = [[UIImageView alloc] init];
            _crownView.image = [UIImage imageNamed:@"crown"];
            [self.contentView addSubview:_crownView];
        }
        if (!_actionButton) {
            _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_HeaderWidth, kTweetCell_HeaderWidth / 3)];
            _actionButton.layer.cornerRadius = kTweetCell_ActionButtonSize.height/2;
            _actionButton.layer.borderWidth = .5f;
            _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
            _actionButton.layer.borderColor = [UIColor blackColor].CGColor;
            [_actionButton addTarget:self action:@selector(handleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_actionButton setTitleColor:SYSFONTCOLOR_BLACK forState:UIControlStateNormal];
            [self.contentView addSubview:_actionButton];
        }
        _sectionImages = [[NSMutableArray alloc] initWithArray:@[[UIImage imageNamed:@"tweet_collection"],[UIImage imageNamed:@"tweet_report"],[UIImage imageNamed:@"tweet_unlike"],[UIImage imageNamed:@"tweet_comment"]]];
        if (!_bottomSegmentedController) {
            _bottomSegmentedController = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, KBottomHeight)];
            _bottomSegmentedController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
            _bottomSegmentedController.sectionTitles = @[@"", @"", @"" ,@""];
            _bottomSegmentedController.sectionImages = _sectionImages.copy;
            _bottomSegmentedController.verticalDividerEnabled = YES;
            _bottomSegmentedController.responseCurrentIndex = YES;
            _bottomSegmentedController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.f],
                                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x9f9f9f"]};
            _bottomSegmentedController.type = HMSegmentedControlTypeTextImages;
            _bottomSegmentedController.verticalDividerColor = [UIColor colorWithHexString:@"0xc8c7cc"];
            _bottomSegmentedController.backgroundColor = [UIColor clearColor];
            _bottomSegmentedController.verticalDividerWidth = .5f;
            [_bottomSegmentedController addLineUp:YES andDown:NO];
            [_bottomSegmentedController addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:_bottomSegmentedController];
        }
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.width.height.mas_equalTo(kTweetCell_HeaderWidth);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(_userHeaderView);
            make.width.mas_greaterThanOrEqualTo(0);
            make.height.mas_equalTo(kTweetCell_HeaderWidth/2);
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(_userHeaderView.mas_bottom).offset(kPaddingLeftWidth);
            make.height.mas_greaterThanOrEqualTo(0);
            make.width.mas_equalTo(KContent_Size);
        }];
        [_crownView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_levelLabel.mas_right).offset(kTweetCell_TitlePadding);
            make.bottom.equalTo(_levelLabel);
            make.width.mas_equalTo(kTweetCell_CrownWidth);
            make.height.mas_equalTo(kTweetCell_CrownHeight);
        }];
        [_actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.width.mas_equalTo(kTweetCell_ActionButtonSize.width);
            make.height.mas_equalTo(kTweetCell_ActionButtonSize.height);
        }];
        if (_imagesView) {
            [_imagesView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_contentLabel.mas_bottom).offset(kPaddingLeftWidth);
                make.left.equalTo(_contentLabel);
                make.width.mas_equalTo(KContent_Size);
                make.height.mas_equalTo(0);
            }];
        }
        //bottomSegmentedController
        [_bottomSegmentedController mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(KBottomHeight);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)resetState:(BOOL)state {
    _showFullContentDetail = state;
    _moreDetailButton.selected = _showFullContentDetail;
    //更新文本高度
    CGFloat contentHeight = [_curTopic.topiccontent getHeightWithFont:kTweetCell_ContentFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
    contentHeight = _showFullContentDetail?contentHeight:MIN(contentHeight, kTweetCell_MaxContentHeight);
    [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
        make.top.equalTo(_timeLabel.mas_bottom).offset(kPaddingLeftWidth);
        make.height.mas_equalTo(contentHeight);
        make.width.mas_equalTo(KContent_Size);
    }];
}

- (void)setTopicType:(TopicType)topicType {
    _topicType = topicType;
    if (_topicType == TopicTypeNormal) {
        [_bottomSegmentedController setHidden:NO];
    } else {
        [_bottomSegmentedController setHidden:YES];
        [_actionButton setTitle:@"删 除" forState:UIControlStateNormal];
    }
}

- (void)setActionType:(ActionType)actionType {
    _actionType = actionType;
    if (_actionType == ActionType_Delete) {
        [_actionButton setTitle:@"删 除" forState:UIControlStateNormal];
        _actionButton.hidden = NO;
    } else {
        [_actionButton setTitle:@"屏 蔽" forState:UIControlStateNormal];
        _actionButton.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    if (!_curTopic) {
        return;
    }
    //user header
    [_userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:curTopic.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    //user name
    CGFloat userNameWidth = [[curTopic owner].username getWidthWithFont:kTweetCell_NameFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, kTweetCell_HeaderWidth/2)];
    _userNameLabel.text = [curTopic owner].username;
    [_userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
        make.top.equalTo(_userHeaderView);
        make.width.mas_equalTo(userNameWidth);
        make.height.mas_equalTo(kTweetCell_HeaderWidth/2);
    }];
    
    //genderIcon
    _genderIconView.image = [[curTopic owner] sexIcon];
    [_genderIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_userNameLabel.mas_right).offset(kTweetCell_TitlePadding);
        make.top.equalTo(_userNameLabel);
        make.width.height.mas_equalTo(kTweetCell_GenderIconWidth);
    }];
    
    NSString *userrank = [curTopic owner].userrank.stringValue;
    _crownView.hidden = ![[userrank substringFromIndex:userrank.length - 1] boolValue];
    //level
    [_levelLabel setText:[NSString stringWithFormat:@"LV.%@",[userrank substringToIndex:userrank.length - 1]]];
    [_levelLabel setBackgroundColor:[[curTopic owner] sexColor]];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_genderIconView.mas_right).offset(kTweetCell_TitlePadding);
        make.centerY.equalTo(_userNameLabel);
        make.width.mas_equalTo(kTweetCell_LevelSize.width);
        make.height.mas_equalTo(kTweetCell_LevelSize.height);
    }];
    //time
    NSString *timeStr = [_curTopic.createdate stringTimesAgo];
    CGSize timeSize = [timeStr getSizeWithFont:kBaseFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    _timeLabel.text = timeStr;
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_userHeaderView);
        make.left.equalTo(_userNameLabel);
        make.width.mas_greaterThanOrEqualTo(0);
        make.height.mas_equalTo(timeSize.height);
    }];
    
    //content
    if (_curTopic.topiccontent.length > 0) { //如果有内容
        CGFloat contentHeight = [_curTopic.topiccontent getHeightWithFont:kTweetCell_ContentFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
        _contentLabel.hidden = NO;
        _contentLabel.text = _curTopic.topiccontent;
        if (contentHeight > kTweetCell_MaxContentHeight) {
            _showMoreDetailButton = YES;
            contentHeight = kTweetCell_MaxContentHeight;
        } else {
            _showMoreDetailButton = NO;
        }
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.top.equalTo(_userHeaderView.mas_bottom).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(contentHeight);
            make.width.mas_equalTo(KContent_Size);
        }];
        
        //show more button
        if (_showMoreDetailButton) {
            _moreDetailButton.hidden = NO;
        } else {
            _moreDetailButton.hidden = YES;
        }
        [_moreDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentLabel.mas_bottom).offset(kTweetCell_TitlePadding);
            make.left.equalTo(_contentLabel);
            make.height.mas_equalTo(kTweetCell_MoreDetailButtonHeight);
        }];
        
        //location
        CGFloat locationHeight = 0;
        _locationLabel.text = _curTopic.location;
        if (_curTopic.location && _curTopic.location.length > 0) {
            locationHeight = [_curTopic.location getHeightWithFont:kBaseFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
        }
        
        //imageView
        if (_imagesView) {
            CGFloat imageViewHeight = [TweetCell heightWithMedias:[_curTopic topicMedium]];
            if (_showMoreDetailButton) {
                [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_moreDetailButton.mas_bottom).offset(kTweetCell_TitlePadding);
                    make.left.equalTo(_contentLabel);
                    make.width.mas_equalTo(KContent_Size - 25); //右边距35.f - 10.f
                    make.height.mas_equalTo(imageViewHeight);
                }];
            } else {
                [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_contentLabel.mas_bottom).offset(kTweetCell_TitlePadding);
                    make.left.equalTo(_contentLabel);
                    make.width.mas_equalTo(KContent_Size - 25); //右边距35.f - 10.f
                    make.height.mas_equalTo(imageViewHeight);
                }];
            }
            
            //location
            [_locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_imagesView.mas_bottom).offset(kTweetCell_ImagePadding);
                make.width.mas_equalTo(KContent_Size);
                make.left.equalTo(_imagesView);
                make.height.mas_equalTo(locationHeight);
            }];
        } else {
            //location
            if (_showMoreDetailButton) {
                [_locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_moreDetailButton.mas_bottom).offset(kTweetCell_ImagePadding + kTweetCell_TitlePadding);
                    make.width.mas_equalTo(KContent_Size);
                    make.left.equalTo(_contentLabel);
                    make.height.mas_equalTo(locationHeight);
                }];
            } else {
                [_locationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_contentLabel.mas_bottom).offset(kTweetCell_ImagePadding);
                    make.width.mas_equalTo(KContent_Size);
                    make.left.equalTo(_contentLabel);
                    make.height.mas_equalTo(locationHeight);
                }];
            }
        }
    } else { //content为空
        _contentLabel.hidden = YES;
        _moreDetailButton.hidden = YES;
        
        CGFloat imageViewHeight = [TweetCell heightWithMedias:[_curTopic topicMedium]];
        [_imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userHeaderView.mas_bottom).offset(kPaddingLeftWidth);
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.width.mas_equalTo(KContent_Size - 25); //右边距35.f - 10.f
            make.height.mas_equalTo(imageViewHeight);
        }];
    }
    
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
    //reload data
    [self.imagesView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj andTweetType:(TopicType)type canShowFullContent:(BOOL)showFullContent{
    CGFloat rowHeight = 0;
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)obj;
        //headerView
        rowHeight += kPaddingLeftWidth + kTweetCell_HeaderWidth;
        
        //content
        CGFloat contentHeight = [curTopic.topiccontent getHeightWithFont:kTweetCell_ContentFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
        
        //showMoreDetailButton
        if (contentHeight > kTweetCell_MaxContentHeight) {
            if (showFullContent) { //点击显示更多按钮
                rowHeight += kPaddingLeftWidth + contentHeight;
            } else {
                rowHeight += kPaddingLeftWidth + kTweetCell_MaxContentHeight;
            }
            rowHeight += kTweetCell_MoreDetailButtonHeight;
        } else {
            rowHeight += kPaddingLeftWidth + contentHeight;
        }
        
        //imageView
        CGFloat imageViewHieght = [TweetCell heightWithMedias:[curTopic topicMedium]];
        rowHeight += kTweetCell_TitlePadding + imageViewHieght;
        
        //location
        if (curTopic.location.length > 0) {
            CGFloat locationHeight = [curTopic.location getHeightWithFont:kBaseFont constrainedToSize:CGSizeMake(KContent_Size, CGFLOAT_MAX)];
            rowHeight += kTweetCell_ImagePadding + locationHeight;
        }
        
        //bottom bar
        if (type == TopicTypeNormal)
            rowHeight += kTweetCell_ImagePadding + KBottomHeight;
        else
            rowHeight += kTweetCell_ImagePadding;
    }
    return rowHeight;
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_curTopic topicMedium].count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetCell_ImagePadding;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kTweetCell_ImagePadding;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [TweetCell itemWidth]; //右边距35.f - 10.f
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
    browser.showTranspondAction = YES;
    browser.showSaveBtn = NO;
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photoArray; // 设置所有的图片
    @weakify(self);
    browser.transpondBlock = ^ (UIImage *transpondImage) {
        @strongify(self);
        if (self.transpondBlock) {
            self.transpondBlock(transpondImage);
        }
    };
    [browser show];
}

+ (CGFloat)itemWidth {
    return (KContent_Size - 25.f - 2*kTweetCell_ImagePadding) / 3;
}

#pragma mark - Private Method
+ (CGFloat)heightWithMedias:(NSArray *)medias {
    CGFloat CHeight = 0;
    CGFloat height = [TweetCell itemWidth];
    NSInteger row = ceilf(medias.count / 3.f);
    CHeight = height * row;
    return CHeight;
}

#pragma mark - Action
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0: {
        }
            break;
        case 1: {
            if (_curTopic.shield.boolValue) { //如果已经被屏蔽,就代表已经举报过
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

- (void)showMoreDetailClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    _showFullContentDetail = !_showFullContentDetail;
    if (_showMoreDetailBlock) {
        _showMoreDetailBlock(sender.selected);
    }
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    if (_userInfoBlock) {
        _userInfoBlock(_curTopic.usercode);
    }
}

- (void)handleButtonClicked:(id)sender {
    if (_actionButtonClickedBlock) {
        _actionButtonClickedBlock(_actionType);
    }
}
@end
