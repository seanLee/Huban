//
//  ApplicationAuthViewController.m
//  Huban
//
//  Created by sean on 15/12/7.
//  Copyright © 2015年 sean. All rights reserved.
//

#import "ApplicationAuthViewController.h"
#import "UIPlaceHolderTextView.h"

@interface ApplicationAuthViewController ()
@property (strong, nonatomic) UIPlaceHolderTextView *textView;
@end

@implementation ApplicationAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"加为好友";
    
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(addFriend)];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    _textView = [[UIPlaceHolderTextView alloc] init];
    
    //textView
    _textView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
    //set Placer
    _textView.placeholder = @"允许不输入内容,可直接点击发送";
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.layer.borderWidth = .5f;
    _textView.font = [UIFont systemFontOfSize:14.f];
    _textView.textColor = SYSFONTCOLOR_BLACK;
    [_textView becomeFirstResponder];
    [self.view addSubview:_textView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kPaddingLeftWidth);
        make.left.equalTo(self.view).offset(kPaddingLeftWidth);
        make.right.equalTo(self.view).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo(150);
    }];
}

#pragma mark - Action
- (void)addFriend {
    if (self.addedFriendBlock) {
        self.addedFriendBlock(self.textView.text);
    }
}
@end
