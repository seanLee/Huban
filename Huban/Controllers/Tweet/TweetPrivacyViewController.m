//
//  TweetPrivacyViewController.m
//  Huban
//
//  Created by sean on 15/9/2.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "TweetPrivacyViewController.h"

@interface TweetPrivacyViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSArray *dataItems;
@end

@implementation TweetPrivacyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"谁可以看";
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = SYSBACKGROUNDCOLOR_DEFAULT;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[TweetPrivacyCell class] forCellReuseIdentifier:kCellIdentifer_TweetPrivacyCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    
    switch (self.topicType) {
        case SendTopicType_ToCityCircle: {
            _dataItems = @[@(TweetPrivacyTyepOpen),
                           @(TweetPrivacyTyepOnlyStranger)];
            }
            break;
        case SendTopicType_ToFriendCircle: {
            _dataItems = @[@(TweetPrivacyTyepOpen),
                           @(TweetPrivacyTyepOnlyFriend)];
        }
            break;
        case SendTopicType_ToAlbum: {
            _dataItems = @[@(TweetPrivacyTyepOpen),
                           @(TweetPrivacyTyepPrivate)];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TweetPrivacyCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetPrivacyCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer_TweetPrivacyCell forIndexPath:indexPath];
    cell.privacyType = [_dataItems[indexPath.row] integerValue];
    if (cell.privacyType == self.privacyType) {
        cell.showCheckmark = YES;
    } else {
        cell.showCheckmark = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.privacyType = [_dataItems[indexPath.row] integerValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (self.topicType) {
        case SendTopicType_ToCityCircle: {
            [defaults setObject:@(self.privacyType) forKey:kTweetType_CityCircle];
        }
            break;
        case SendTopicType_ToFriendCircle: {
             [defaults setObject:@(self.privacyType) forKey:kTweetType_FriendCircle];
        }
            break;
        case SendTopicType_ToAlbum: {
             [defaults setObject:@(self.privacyType) forKey:kTweetType_Album];
        }
            break;
        default:
            break;
    }
    
    if (_didSelectedPrivacyType) {
        _didSelectedPrivacyType(self.privacyType);
    }
    [self.myTableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

#define kTweetPrivacyCell_CheckmarkWidth 24.f

@interface TweetPrivacyCell ()
@property (strong, nonatomic) UILabel *titleL;
@property (strong, nonatomic) UILabel *detailL;
@property (strong, nonatomic) UIButton *checkmarkButton;
@end

@implementation TweetPrivacyCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectZero];
            _titleL.font = kBaseFont;
            _titleL.textColor = SYSFONTCOLOR_BLACK;
            _titleL.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_titleL];
        }
        if (!_detailL) {
            _detailL = [[UILabel alloc] initWithFrame:CGRectZero];
            _detailL.font = [UIFont systemFontOfSize:12.f];
            _detailL.textColor = [UIColor colorWithHexString:@"0x999999"];
            _detailL.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_detailL];
        }
        if (!_checkmarkButton) {
            _checkmarkButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [_checkmarkButton setImage:[UIImage imageNamed:@"checkmark_Box"] forState:UIControlStateNormal];
            [_checkmarkButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateSelected];
            [self.contentView addSubview:_checkmarkButton];
        }
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView);
            make.right.equalTo(_checkmarkButton.mas_left).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo([TweetPrivacyCell cellHeight]/2);
        }];
        [_detailL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(_titleL.mas_bottom);
            make.right.equalTo(_checkmarkButton.mas_left).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo([TweetPrivacyCell cellHeight]/2);
        }];
        [_checkmarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(kTweetPrivacyCell_CheckmarkWidth);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)setPrivacyType:(TweetPrivacyTyep)privacyType {
    _privacyType = privacyType;
    switch (_privacyType) {
        case TweetPrivacyTyepOpen: {
            _titleL.text = @"公开";
            _detailL.text = @"同时发布到好友生活和同城,所有人可见";
        }
            break;
        case TweetPrivacyTyepOnlyFriend: {
            _titleL.text = @"好友可见";
            _detailL.text = @"显示在生活圈,仅通讯录好友可见";
        }
            break;
        case TweetPrivacyTyepOnlyStranger: {
            _titleL.text = @"陌生人可见";
            _detailL.text = @"显示在同城,通讯录好友不可见";
        }
            break;
        case TweetPrivacyTyepPrivate: {
            _titleL.text = @"私密";
            _detailL.text = @"显示在我的相册,仅自己可见";
        }
            break;
        default:
            break;
    }
}

- (void)setTitleStr:(NSString *)titleStr andDetailStr:(NSString *)detailStr {
    _titleL.text = titleStr;
    _detailL.text = detailStr;
}

- (void)setShowCheckmark:(BOOL)showCheckmark {
    _showCheckmark = showCheckmark;
    _checkmarkButton.selected = _showCheckmark;
}

+ (CGFloat)cellHeight {
    return 44.f;
}
@end
