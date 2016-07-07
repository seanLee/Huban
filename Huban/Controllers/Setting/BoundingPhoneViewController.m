//
//  BoundingPhoneViewController.m
//  Huban
//
//  Created by sean on 15/8/14.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "BoundingPhoneViewController.h"
#import "PhoneSettingViewController.h"

@interface BoundingPhoneViewController ()
@property (strong, nonatomic) UILabel *phoneLabel;
@end

@implementation BoundingPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"绑定手机号码";
    
    //imageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 179.f, 179.f)];
    imageView.image = [UIImage imageNamed:@"boundingPhone"];
    [self.view addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(36);
        make.width.height.mas_equalTo(179);
        make.centerX.equalTo(self.view);
    }];
    
    //label
    _phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _phoneLabel.textColor = SYSFONTCOLOR_BLACK;
    _phoneLabel.font = [UIFont systemFontOfSize:16.f];
    _phoneLabel.text = [NSString stringWithFormat:@"绑定的手机号:%@",[Login curLoginUser].usermobile];
    [_phoneLabel sizeToFit];
    [self.view addSubview:_phoneLabel];
    
    [_phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(22);
        make.centerX.equalTo(self.view);
    }];
    
    //button
    UIButton *button = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"修改绑定手机" andFrame:CGRectMake(0, 0, 50.f, 35.f) target:self action:@selector(gotoModefyBouding:)];
    [self.view addSubview:button];

    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phoneLabel.mas_bottom).offset(98);
        make.left.equalTo(self.view).offset(23);
        make.right.equalTo(self.view).offset(-23);
        make.height.mas_equalTo(35);
    }];
}

#pragma mark - Action
- (void)gotoModefyBouding:(id)sender {
    PhoneSettingViewController *vc = [[PhoneSettingViewController alloc] init];
    vc.changeMobileBlock = ^ {
        _phoneLabel.text = [NSString stringWithFormat:@"绑定的手机号:%@",[Login curLoginUser].usermobile];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
@end
