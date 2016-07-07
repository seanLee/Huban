//
//  SendLocationCell.m
//  Huban
//
//  Created by sean on 15/12/4.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "SendLocationCell.h"

@interface SendLocationCell ()
@property (strong, nonatomic) UILabel *addressLbl;
@property (strong, nonatomic) UILabel *nameLbl;
@end

@implementation SendLocationCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        {
            _nameLbl = [[UILabel alloc] initWithFrame:CGRectZero];
            _nameLbl.font = [UIFont systemFontOfSize:14.f];
            _nameLbl.textColor = SYSFONTCOLOR_BLACK;
            [self.contentView addSubview:_nameLbl];
        }
        {
            _addressLbl = [[UILabel alloc] initWithFrame:CGRectZero];
            _addressLbl.font = [UIFont systemFontOfSize:12.f];
            _addressLbl.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_addressLbl];
        }
        [_nameLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo([[self class] cellHeight]/2);
        }];
        [_addressLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nameLbl.mas_bottom);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo([[self class] cellHeight]/2);
        }];
    }
    return self;
}

- (void)setName:(NSString *)nameStr {
    self.nameLbl.text = nameStr;
}

- (void)setAddress:(NSString *)addressStr {
    self.addressLbl.text = addressStr;
}

+ (CGFloat)cellHeight {
    return 40.f;
}
@end
