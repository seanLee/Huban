//
//  AlbumCell.m
//  Huban
//
//  Created by sean on 15/9/3.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAlbumListCell_DateLabelHeight 21.f
#define kAlbumListCell_DateLabelWidth 45.f
#define kAlbumListCell_ImageWidth 65.f
#define kAlbumListCell_HeaderHeight 4.f
#define kAlbumListCell_ContentFont kBaseFont

#import "AlbumListCell.h"
#import "AlbumCell.h"

@interface AlbumListCell () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UIImageView *imgView;
@end

@implementation AlbumListCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_dateLabel) {
            _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _dateLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:_dateLabel];
        }
        if (!_myTableView) {
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
                tableView.delegate = self;
                tableView.dataSource = self;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                tableView.scrollEnabled = NO;
                [tableView registerClass:[AlbumCell class] forCellReuseIdentifier:kCellIdentifier_AlbumCell];
                [tableView registerClass:[AlbumCell class] forCellReuseIdentifier:kCellIdentifier_AlbumCellWithImages];
                [self.contentView addSubview:tableView];
                tableView;
            });
            if ([reuseIdentifier isEqualToString:kCellIdentifier_AlbumListCell_Index]) {
                _myTableView.tableHeaderView = [self customerHeaderView];
            }
        }
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView);
            make.width.mas_equalTo(kAlbumListCell_DateLabelWidth);
            make.height.mas_equalTo(kAlbumListCell_DateLabelHeight);
        }];
        [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
            make.left.equalTo(_dateLabel.mas_right).offset(kPaddingLeftWidth/2);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (UIView *)customerHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width,kAlbumListCell_ImageWidth+4.f)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAlbumListCell_ImageWidth, kAlbumListCell_ImageWidth)];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTweet)];
    [imageView addGestureRecognizer:tap];
    [imageView setImage:[UIImage imageNamed:@"uploadImage"]];
    [headerView addSubview:imageView];

    return headerView;
}

- (void)setTopics:(NSArray *)topics {
    _topics = topics;
    if (!_topics || topics.count == 0) {
        _dateLabel.attributedText = [self todayStr];
        return;
    }
    _dateLabel.attributedText = [self dateStr];
    [self.myTableView reloadData];
}

+ (CGFloat)cellHeightWidhObj:(id)obj isIndex:(BOOL)index{
    CGFloat cellHeight = 0;
    if (index) {
        cellHeight = kAlbumListCell_ImageWidth + 4.f;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *topics = (NSArray *)obj;
        for (Topic *curItem in topics) {
            cellHeight += [AlbumCell cellHeigthWithObj:curItem];
        }
        if (topics.count > 0) {
            cellHeight += ((topics.count - 1) * kAlbumListCell_HeaderHeight);
        }
    }
    return cellHeight;
}

#pragma mark - Action
- (void)newTweet {
    if (_addPhotoBlock) {
        _addPhotoBlock();
    }
}

#pragma mark - Private Method
- (NSAttributedString *)todayStr {
    NSDate *curDate = [NSDate date];
    NSInteger day  = [curDate day];
    NSInteger month = [curDate month];
    NSString *dayStr;
    NSString *monthStr = [NSString stringWithFormat:@" %@月",@(month)];
    
    if (day < 10) {
        dayStr = [NSString stringWithFormat:@"0%@",@(day)];
    } else {
        dayStr = [NSString stringWithFormat:@"%@",@(day)];
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:dayStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                   NSFontAttributeName:[UIFont boldSystemFontOfSize:16.f]}]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:monthStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                     NSFontAttributeName:[UIFont systemFontOfSize:10.f]}]];
    return [attrStr copy];
}

- (NSAttributedString *)dateStr {
    NSDate *curDate = ((Topic *)_topics.firstObject).createdate;
    NSInteger day  = [curDate day];
    NSInteger month = [curDate month];
    NSString *dayStr;
    NSString *monthStr = [NSString stringWithFormat:@" %@月",@(month)];
    
    if (day < 10) {
        dayStr = [NSString stringWithFormat:@"0%@",@(day)];
    } else {
        dayStr = [NSString stringWithFormat:@"%@",@(day)];
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:dayStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                   NSFontAttributeName:[UIFont boldSystemFontOfSize:16.f]}]];
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:monthStr attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                     NSFontAttributeName:[UIFont systemFontOfSize:10.f]}]];
    
    return [attrStr copy];
}

#pragma mark - TabelView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _topics.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AlbumCell cellHeigthWithObj:_topics[indexPath.section]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0?0:kAlbumListCell_HeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView getHeaderViewWithStr:@"" andHeight:kAlbumListCell_HeaderHeight color:[UIColor clearColor] andBlock:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell;
    Topic *curTopic = _topics[indexPath.section];
    if (curTopic.topicMedium.count == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AlbumCell forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_AlbumCellWithImages forIndexPath:indexPath];
    }
    cell.curTopic = curTopic;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Topic *curTopic = _topics[indexPath.section];
    if (self.itemSelectedBlock) {
        self.itemSelectedBlock(curTopic);
    }
}
@end
