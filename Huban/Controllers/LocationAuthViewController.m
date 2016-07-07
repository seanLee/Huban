//
//  LocationAuthViewController.m
//  Huban
//
//  Created by sean on 15/12/16.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "LocationAuthViewController.h"
#import "AroundViewController.h"

@interface LocationAuthViewController ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *textLbl;
@property (strong, nonatomic) UIButton *searchButton;
@end

@implementation LocationAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"周边的人";
    
    _iconView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"discover"];
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(80.f);
            make.centerX.equalTo(self.view);
            make.width.mas_equalTo(81.f);
            make.height.mas_equalTo(128.f);
        }];
        imageView;
    });
    _textLbl = ({
        UILabel *lbl = [[UILabel alloc] init];
        lbl.font = [UIFont systemFontOfSize:14.f];
        lbl.textColor = SYSBACKGROUNDCOLOR_BLUE;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.numberOfLines = 6;
        lbl.text = @"对通讯录的好友进行了隐身\n避免遇见熟人的尴尬";
        [self.view addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.iconView.mas_bottom).offset(40.f);
            make.height.mas_greaterThanOrEqualTo(0);
        }];
        lbl;
    });
    _searchButton = ({
        UIButton *btn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"开始查找" andFrame:CGRectMake(1, 1, 1, 1) target:self action:@selector(search:)];
        btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(kPaddingLeftWidth);
            make.right.equalTo(self.view).offset(-kPaddingLeftWidth);
            make.top.equalTo(self.textLbl.mas_bottom).offset(40.f);
            make.height.mas_equalTo(35.f);
        }];
        btn;
    });
}


#pragma mark - Action
- (void)search:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:kLocationAuth];
    AroundViewController *vc = [[AroundViewController alloc] init];
    
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers replaceObjectAtIndex:1 withObject:vc];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
}
@end
