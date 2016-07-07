//
//  TweetCommentCell.m
//  Huban
//
//  Created by sean on 15/8/20.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetCommentCellHeaderWidth 30.f
#define kTweetCommentCellLeftMargin (4*kPaddingLeftWidth + kTweetCommentCellHeaderWidth + 16.f)
#define kTweetCommentCellContentWidth (kScreen_Width - kTweetCommentCellLeftMargin - 2*kPaddingLeftWidth)
#define kTweetCommentCellBottomMargin 5.f

#import "TweetCommentCell.h"
#import "UITTTAttributedLabel.h"

@interface TweetCommentCell () <TTTAttributedLabelDelegate>
@property (strong, nonatomic) UIImageView *userHeaderView;
@property (strong, nonatomic) UITTTAttributedLabel *titleLabel;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation TweetCommentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (!_userHeaderView) {
            _userHeaderView = [[UIImageView alloc] init];
            [self.contentView addSubview:_userHeaderView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
            _contentLabel.font = [UIFont systemFontOfSize:14.f];
            _contentLabel.numberOfLines = 0;
            [_contentLabel addLongPressForCopyWithBGColor:[UIColor colorWithHexString:@"0xf0f0f0"] andNormalColor:[UIColor clearColor]];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_titleLabel) {
            _titleLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
            _titleLabel.font = [UIFont systemFontOfSize:12.f];
            _titleLabel.delegate = self;
            _titleLabel.linkAttributes = kLinkAttributes;
            _titleLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_titleLabel];
        }
        [_userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(kTweetCommentCellBottomMargin);
            make.width.height.mas_equalTo(kTweetCommentCellHeaderWidth);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userHeaderView.mas_top);
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(_userHeaderView.mas_height).dividedBy(2);
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_userHeaderView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView).offset(-kTweetCommentCellBottomMargin);
            make.top.equalTo(self.titleLabel.mas_bottom);
        }];
    }
    return self;
}

- (void)setCurComment:(TopicComment *)curComment {
    _curComment = curComment;
    if (!_curComment) {
        return;
    }
    [_userHeaderView sd_setImageWithURL:[NSURL thumbImageURLWithString:_curComment.userlogourl] placeholderImage:[UIImage avatarPlacer]];
    if (_curComment.feedbackcode && ![_curComment.feedbackcode isEmpty]) {
        _titleLabel.text = [NSString stringWithFormat:@"%@回复%@:",_curComment.username,_curComment.feedbackname];
    } else {
        _titleLabel.text = [NSString stringWithFormat:@"%@:",_curComment.username];
    }
    _contentLabel.text = curComment.commentcontent;
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat rowHeight = 0;
    if ([obj isKindOfClass:[TopicComment class]]) {
        TopicComment *curComment = (TopicComment *)obj;
        rowHeight += kTweetCommentCellBottomMargin;
        rowHeight += (kTweetCommentCellHeaderWidth / 2.f);
        
        //content
        CGFloat contentHeight = [curComment.commentcontent getHeightWithFont:[UIFont systemFontOfSize:14.f] constrainedToSize:CGSizeMake(kTweetCommentCellContentWidth, CGFLOAT_MAX)];
        rowHeight += contentHeight;
        rowHeight += kTweetCommentCellBottomMargin;
    }
    return rowHeight;
}

#pragma mark - Draw Rect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    NSString *titleTex = self.titleLabel.text;
    @weakify(self);
    [self.titleLabel setText:titleTex afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        @strongify(self);
        //设置可点击文字的范围
        NSRange senderRange = [[mutableAttributedString string] rangeOfString:self.curComment.username options:NSCaseInsensitiveSearch];
        NSRange feedbackRange = [[mutableAttributedString string] rangeOfString:self.curComment.feedbackname options:NSCaseInsensitiveSearch];
        //设定可点击文字的的大小
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:12.f];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:senderRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName  value:(__bridge id)font range:senderRange];
            
            [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:feedbackRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName  value:(__bridge id)font range:feedbackRange];
        }
        
        return mutableAttributedString;
    }];
    
    NSRange senderRange = [titleTex rangeOfString:self.curComment.username options:NSCaseInsensitiveSearch];
    [self.titleLabel addLinkToTransitInformation:@{@"usercode":self.curComment.usercode} withRange:senderRange];
    
    NSRange feedbackRange = [titleTex rangeOfString:self.curComment.feedbackname options:NSCaseInsensitiveSearch];
    [self.titleLabel addLinkToTransitInformation:@{@"usercode":self.curComment.feedbackcode} withRange:feedbackRange];
    
    [self.titleLabel setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components {
    if (self.didTapLinkBlock) {
        self.didTapLinkBlock(components);
    }
}
@end
