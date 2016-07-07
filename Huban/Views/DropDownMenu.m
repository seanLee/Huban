//
//  DropDownMenu.m
//  Huban
//
//  Created by sean on 15/8/31.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kDropDownMenu_OneLineHeight 44.f
#define kDropDownMenu_ContentWidth 120.f
#define kDropDownMenu_IndicatorViewHeight 6.f

#import "DropDownMenu.h"

@interface DropDownMenu () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UITableView *myTableView;
@end

@implementation DropDownMenu
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setDataItem:(NSArray *)dataItem {
    _dataItem = dataItem;
    if (!_dataItem || _dataItem.count == 0) {
        return;
    }
    CGFloat viewHeight = _dataItem.count * kDropDownMenu_OneLineHeight + kDropDownMenu_IndicatorViewHeight;//indicator height
    if (!_myTableView) {
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.scrollEnabled = NO;
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[DropDownMenuCell class] forCellReuseIdentifier:kCellIdentifier_DropDownMenuCell];
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(kMySegmentControl_Height + kStatusBar_Height);
                make.right.equalTo(self).offset(-kPaddingLeftWidth);
                make.width.mas_equalTo(kDropDownMenu_ContentWidth);
                make.height.mas_equalTo(viewHeight);
            }];
            tableView;
        });
        _myTableView.tableHeaderView = [self customerHeader];
    }
    [_myTableView reloadData];
}

- (UIView *)customerHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDropDownMenu_ContentWidth, kDropDownMenu_IndicatorViewHeight)];
    header.backgroundColor = [UIColor colorWithHexString:@"0x595959"];
    
    UIBezierPath *indicatorPath = [[UIBezierPath alloc] init];
    [indicatorPath moveToPoint:CGPointMake(kDropDownMenu_ContentWidth - 3*kDropDownMenu_IndicatorViewHeight, kDropDownMenu_IndicatorViewHeight)];
    [indicatorPath addLineToPoint:CGPointMake(kDropDownMenu_ContentWidth - 2.5*kDropDownMenu_IndicatorViewHeight, 0)];
    [indicatorPath addLineToPoint:CGPointMake(kDropDownMenu_ContentWidth - 2*kDropDownMenu_IndicatorViewHeight, kDropDownMenu_IndicatorViewHeight)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = indicatorPath.CGPath;
    
    header.layer.mask = maskLayer;
    return header;
}

- (void)hide {
    if (_cancleBlock) {
        _cancleBlock(self);
    }
}

- (void)showInView:(UIView *)aView {
    [aView addSubview:self];
    _myTableView.x = kScreen_Width;
    _myTableView.y = kMySegmentControl_Height + kStatusBar_Height;
    [UIView animateWithDuration:0.35 animations:^{
        _myTableView.x = kScreen_Width - kPaddingLeftWidth - kDropDownMenu_ContentWidth;
    }];
}

#pragma mark - Action
- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [UIView animateWithDuration:0.35 animations:^{
        _myTableView.x = kScreen_Width;
    } completion:^(BOOL finished) {
        _myTableView.alpha = 0;
        if (_cancleBlock) {
            _cancleBlock(self);
        }
    }];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataItem.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DropDownMenuCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DropDownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_DropDownMenuCell forIndexPath:indexPath];
    [cell setTextStr:_dataItem[indexPath.row]];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_clickedIndexBlock) {
        _clickedIndexBlock(indexPath.row);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint curPoint = [touch locationInView:_myTableView];
    CGFloat viewHeight = _dataItem.count * kDropDownMenu_OneLineHeight + kDropDownMenu_IndicatorViewHeight;//indicator height
    if (curPoint.x >= 0 && curPoint.x <= kDropDownMenu_ContentWidth && curPoint.y >= 0 && curPoint.y <= viewHeight) {
        return NO;
    }
    return YES;
}
@end

@interface DropDownMenuCell ()
@property (strong, nonatomic) UILabel *textL;
@end

@implementation DropDownMenuCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0x595959"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textL) {
            _textL = [[UILabel alloc] initWithFrame:self.bounds];
            _textL.backgroundColor = [UIColor clearColor];
            _textL.textColor = [UIColor whiteColor];
            _textL.font = kBaseFont;
            _textL.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_textL];
        }
    }
    return self;
}

- (void)setTextStr:(NSString *)textStr {
    [_textL fitToText:textStr];
    _textL.center = CGPointMake(kDropDownMenu_ContentWidth/2, [DropDownMenuCell cellHeight]/2);
}

+ (CGFloat)cellHeight {
    return 44.f;
}

@end
