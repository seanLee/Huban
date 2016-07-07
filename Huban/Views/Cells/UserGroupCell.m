//
//  UserGroupCell.m
//  Huban
//
//  Created by sean on 15/8/18.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kUserGroupCell_IndicatorWidth 8.f
#define kUserGroupCell_IndicatorHeight 10.f
#define kUserGroupCellHeightForOneLine 44.f

#import "UserGroupCell.h"

@interface UserGroupCell ()
@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UILabel *groupTitleLabel;
@property (strong, nonatomic) UITableView *myTableView;

@property (assign, nonatomic) BOOL hasDropDown;
@end

@implementation UserGroupCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_titleView) {
            _titleView = [[UIView alloc] initWithFrame:CGRectZero];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            [_titleView addGestureRecognizer:tap];
            _titleView.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_titleView];
        }
        if (!_indicatorView) {
            _indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
            _indicatorView.backgroundColor = [UIColor lightGrayColor];
            [_titleView addSubview:_indicatorView];
        }
        if (!_groupTitleLabel) {
            _groupTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _groupTitleLabel.font = [UIFont systemFontOfSize:14.f];
            _groupTitleLabel.textColor = SYSFONTCOLOR_BLACK;
            _groupTitleLabel.textAlignment = NSTextAlignmentLeft;
            [_titleView addSubview:_groupTitleLabel];
        }
        if (!_myTableView) {
            _myTableView = ({
                UITableView *tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [self.contentView addSubview:tableView];
                tableView;
            });
        }
        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView);
            make.height.mas_equalTo(kUserGroupCellHeightForOneLine);
        }];
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(_titleView);
            make.width.height.mas_equalTo(kUserGroupCell_IndicatorHeight);
        }];
        [_groupTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_indicatorView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(_titleView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(_titleView);
            make.height.mas_equalTo(kUserGroupCellHeightForOneLine);
        }];
        [_myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleView.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        //add indicator
        [self addIndicatorLayer];
    }
    return self;
}

- (void)setGroupTitleStr:(NSString *)title {
    _groupTitleLabel.text = title;
}

+ (CGFloat)cellHeightWithDataItms:(NSArray *)dataItems andDropList:(BOOL)showDropDown {
    CGFloat rowHeight;
    if (showDropDown) {
        rowHeight = dataItems.count * kUserGroupCellHeightForOneLine;
    } else {
        rowHeight = kUserGroupCellHeightForOneLine;
    }
    
    return rowHeight;
}

#pragma mark - Draw
- (void)addIndicatorLayer {
    
    UIBezierPath *trianglePath = [[UIBezierPath alloc] init];
    [trianglePath moveToPoint:CGPointMake(0, 0)];
    [trianglePath addLineToPoint:CGPointMake(kUserGroupCell_IndicatorWidth, kUserGroupCell_IndicatorHeight/2)];
    [trianglePath addLineToPoint:CGPointMake(0, kUserGroupCell_IndicatorHeight)];
    [trianglePath closePath];
    
    CAShapeLayer *triangleLayer = [CAShapeLayer layer];
    triangleLayer.path = trianglePath.CGPath;
    
    [_indicatorView.layer setMask:triangleLayer];
}

#pragma mark - Action
- (void)handleTap:(UIGestureRecognizer *)recognizer {
    _hasDropDown = !_hasDropDown;
    [UIView animateWithDuration:0.25 animations:^{
        if (_hasDropDown) {
            _indicatorView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
        } else {
            _indicatorView.layer.transform = CATransform3DIdentity;
        }
    } completion:^(BOOL finished) {
        if (_groupTitleTapBlock) {
            _groupTitleTapBlock(_hasDropDown);
        }

    }];
}
@end
