//
//  AddCustomerCell.m
//  Huban
//
//  Created by sean on 15/8/6.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kAddCustomerCell_IconWidth 28.f

#import "AddCustomerCell.h"

@interface AddCustomerCell ()
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UITextField *inputTextFiled;
@end

@implementation AddCustomerCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_iconImageView) {
            _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAddCustomerCell_IconWidth, kAddCustomerCell_IconWidth/2.f)];
            _iconImageView.backgroundColor = [UIColor redColor];
            [self.contentView addSubview:_iconImageView];
        }
        if (!_inputTextFiled) {
            _inputTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
            _inputTextFiled.placeholder = @"请输入手机号,呼伴号";
            _inputTextFiled.backgroundColor = [UIColor redColor];
            [self.contentView addSubview:_inputTextFiled];
        }
        [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.width.mas_equalTo(kAddCustomerCell_IconWidth);
            make.height.mas_equalTo(kAddCustomerCell_IconWidth/2);
        }];
        [_inputTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconImageView.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

+ (CGFloat)cellHeight {
    return 44.f;
}
@end
