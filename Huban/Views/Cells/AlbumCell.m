//
//  AlbumCell.m
//  Huban
//
//  Created by sean on 15/9/4.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAlbumCell_MinContentHeight 21.f
#define kAlbumCell_MaxContentHeight 32.f //计算所得
#define kAlbumCell_MaxContentHeightWithImage 32.f //计算所的
#define kAlbumCell_ImageWidth 65.f
#define kAlbumCell_PadingLeft 45.f
#define kAlbumCell_CountLabelSize CGSizeMake(31.f, 15.f)
#define kAlbumCell_PrivacyImageWidth 16.f

#import "AlbumCell.h"
#import "UITTTAttributedLabel.h"

@interface AlbumCell ()
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UIImageView *privacyView;
@property (strong, nonatomic) UILabel *imagesCountLabel;
@end

@implementation AlbumCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
            _contentLabel.font = kBaseFont;
            _contentLabel.numberOfLines = 0;
            _contentLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2f];
            UIColor *color = [UIColor colorWithHexString:@"0xf0f0f0"];
            [_contentLabel addLongPressForCopyWithBGColor:color andNormalColor:color];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_privacyView) {
            _privacyView = [[UIImageView alloc] init];
            [self.contentView addSubview:_privacyView];
        }
        [_privacyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentLabel.mas_centerY);
            make.width.height.mas_equalTo(kAlbumCell_PrivacyImageWidth);
        }];
        if ([reuseIdentifier isEqualToString:kCellIdentifier_AlbumCellWithImages]) {
            if (!_coverImageView) {
                _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAlbumCell_ImageWidth, kAlbumCell_ImageWidth)];
                [self.contentView addSubview:_coverImageView];
            }
            if (!_imagesCountLabel) {
                _imagesCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                _imagesCountLabel.font = [UIFont systemFontOfSize:12.f];
                _imagesCountLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
                [self.contentView addSubview:_imagesCountLabel];
            }
            [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.top.equalTo(self.contentView);
                make.width.height.mas_equalTo(kAlbumCell_ImageWidth);
            }];
            [_imagesCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_coverImageView.mas_right).offset(kPaddingLeftWidth);
                make.bottom.equalTo(_coverImageView);
                make.height.mas_greaterThanOrEqualTo(0);
                make.width.mas_greaterThanOrEqualTo(0);
            }];
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_coverImageView);
                make.left.equalTo(_coverImageView.mas_right).offset(kPaddingLeftWidth);
                make.right.equalTo(self.contentView);
                make.bottom.equalTo(_imagesCountLabel.mas_top).offset(4);
            }];
        }
    }
    return self;
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    //显示内容
    if (_curTopic.topiccontent && ![_curTopic.topiccontent isEmpty]) {
        _contentLabel.hidden = NO;
        _contentLabel.text = _curTopic.topiccontent;
    } else {
        _contentLabel.hidden = YES;
    }
    self.privacyView.hidden = NO; //先显示出来
    switch (_curTopic.visibletype.integerValue) {
        case 0: {
            self.privacyView.hidden = YES;
        }
            break;
        case 1: {
            self.privacyView.image = [UIImage imageNamed:@"topic_privacy_friendCircle"];
        }
            break;
        case 2: {
            self.privacyView.image = [UIImage imageNamed:@"topic_privacy_cityCircle"];
        }
            break;
        case 3: {
            self.privacyView.image = [UIImage imageNamed:@"topic_privacy_private"];
        }
            break;
        default:
            break;
    }
    
    if (_curTopic.topicMedium.count == 0) { //不显示图片
        CGSize constrainedSize = CGSizeMake(kScreen_Width - kAlbumCell_PadingLeft -2*kPaddingLeftWidth - kPaddingLeftWidth/2, kAlbumCell_MaxContentHeight);
        CGFloat contentHeight = [_curTopic.topiccontent getHeightWithFont:kBaseFont constrainedToSize:constrainedSize];
        contentHeight = MAX(kAlbumCell_MinContentHeight, contentHeight);
        //relocation
        if (_curTopic.topicImageArray.count == 0) { //不显示图片,添加约束
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(contentHeight);
                make.left.equalTo(self.contentView);
                make.right.equalTo(self.contentView).offset(-kAlbumCell_PrivacyImageWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
    } else { //显示图片
        [_coverImageView sd_setImageWithURL:_curTopic.topicMedium.firstObject];
        NSString *countStr = [NSString stringWithFormat:@"共%@张",@(_curTopic.topicMedium.count)];
        _imagesCountLabel.text = countStr;
        CGSize constrainedSize = CGSizeMake(kScreen_Width - kAlbumCell_PadingLeft - kAlbumCell_CountLabelSize.width -3*kPaddingLeftWidth - kPaddingLeftWidth/2, kAlbumCell_MaxContentHeightWithImage);
        CGFloat contentHeight = MIN(kAlbumCell_MinContentHeight, MAX([_curTopic.topiccontent getHeightWithFont:kBaseFont constrainedToSize:constrainedSize], kAlbumCell_MinContentHeight)) ;
        [_contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_coverImageView);
            make.left.equalTo(_coverImageView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kAlbumCell_PrivacyImageWidth);
            make.height.mas_equalTo(contentHeight);
        }];
    }
}

+ (CGFloat)cellHeigthWithObj:(id)obj {
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *curTopic = (Topic *)obj;
        if (curTopic.topicMedium.count == 0) { //不显示图片
            CGSize constrainedSize = CGSizeMake(kScreen_Width - kAlbumCell_PadingLeft -2*kPaddingLeftWidth - kPaddingLeftWidth/2, kAlbumCell_MaxContentHeight);
            CGFloat contentHeight = [curTopic.topiccontent getHeightWithFont:kBaseFont constrainedToSize:constrainedSize];
            cellHeight = MAX(kAlbumCell_MinContentHeight, contentHeight);
        } else { //显示图片
            cellHeight = kAlbumCell_ImageWidth;
        }
    }
    return cellHeight;
}
@end
