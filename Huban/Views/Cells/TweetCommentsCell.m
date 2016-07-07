//
//  TweetCommentsCell.m
//  Huban
//
//  Created by sean on 15/8/19.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kTweetCommentsCell_Width 16.f
#define kTweetCommentsCell_ContentWidth (kScreen_Width - 4*kPaddingLeftWidth - kTweetLikesButton_Width)
#define kTweetCommentsCell_OneLineHeight 44.f

#import "TweetCommentsCell.h"
#import "TweetCommentCell.h"

@interface TweetCommentsCell () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation TweetCommentsCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_commentButton) {
            _commentButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [_commentButton setImage:[UIImage imageNamed:@"tweet_comment"] forState:UIControlStateNormal];
            [_commentButton addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_commentButton];
        }
        if (!_myTableView) {
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
                tableView.backgroundColor = [UIColor clearColor];
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.scrollEnabled = NO;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [tableView registerClass:[TweetCommentCell class] forCellReuseIdentifier:kCellIdentifier_TweetCommentCell];
                [self.contentView addSubview:tableView];
                tableView;
            });
        }
        [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(2*kPaddingLeftWidth);
            make.top.mas_equalTo((36.f-kTweetCommentsCell_Width)/2);
            make.width.height.mas_equalTo(kTweetCommentsCell_Width);
        }];
        [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_commentButton.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setCurTopic:(Topic *)curTopic {
    _curTopic = curTopic;
    if (!_curTopic) {
        return;
    }
    [self.myTableView reloadData];
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    CGFloat cellHeight;
    if ([obj isKindOfClass:[Topic class]]) {
        Topic *topic = (Topic *)obj;
        if (topic.comment_list.count == 0) {
            cellHeight = kTweetCommentsCell_OneLineHeight;
        } else {
            cellHeight = kTweetCommentsCell_OneLineHeight * topic.comment_list.count;
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
    
    CGContextMoveToPoint(context, kPaddingLeftWidth, 0);
    CGContextAddLineToPoint(context, rectWidth - kPaddingLeftWidth, 0);
    CGContextAddLineToPoint(context, rectWidth - kPaddingLeftWidth, rectHeight);
    CGContextAddLineToPoint(context, kPaddingLeftWidth, rectHeight);
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Action
- (void)commentButtonClicked:(id)sender {
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _curTopic.comment_list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TweetCommentCell cellHeightWithObj:_curTopic.comment_list[indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetCommentCell forIndexPath:indexPath];
    TopicComment *curComment = _curTopic.comment_list[indexPath.row];
    if (curComment) {
        cell.curComment = curComment;
    }
    @weakify(self);
    cell.didTapLinkBlock = ^ (NSDictionary *dict) {
        @strongify(self);
        if (self.didTapLinkBlock) {
            self.didTapLinkBlock(dict);
        }
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TopicComment *curComment = _curTopic.comment_list[indexPath.row];
    if ([curComment.usercode isEqualToString:[Login curLoginUser].usercode]) {
        @weakify(self);
        [UIAlertView bk_showAlertViewWithTitle:@"是否删除该条评论" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"删除"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            @strongify(self);
            if (buttonIndex == 1) {
                if (self.deleteCommentBlock) {
                    self.deleteCommentBlock(curComment);
                }
            }
        }];
    } else {
        if (self.commentButtonClicked) {
            self.commentButtonClicked(curComment);
        }
    }
}
@end
