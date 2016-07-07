//
//  FeedBakcViewController.m
//  Huban
//
//  Created by sean on 15/8/13.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#import "FeedBakcViewController.h"
//#import "SZTextView.h"
#import "UIPlaceHolderTextView.h"

@interface FeedBakcViewController () <UITextViewDelegate>
@property (strong, nonatomic) UIPlaceHolderTextView *feedBackTextView;
@end

@implementation FeedBakcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"意见反馈";
    
    //textView
    _feedBackTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectZero];
    //set Placer
    _feedBackTextView.placeholder = @"请输入您的反馈意见";
    _feedBackTextView.returnKeyType = UIReturnKeyDone;
    _feedBackTextView.backgroundColor = [UIColor whiteColor];
    _feedBackTextView.delegate = self;
    _feedBackTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _feedBackTextView.layer.borderWidth = .5f;
    _feedBackTextView.font = [UIFont systemFontOfSize:14.f];
    _feedBackTextView.textColor = SYSFONTCOLOR_BLACK;
    [_feedBackTextView becomeFirstResponder];
    [self.view addSubview:_feedBackTextView];
    
    [_feedBackTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kPaddingLeftWidth);
        make.left.equalTo(self.view).offset(kPaddingLeftWidth);
        make.right.equalTo(self.view).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo(150);
    }];
    
    //right itemBar
    UIBarButtonItem *sendItem = [UIBarButtonItem itemWithBtnTitle:@"发送" target:self action:@selector(sendMessage)];
    self.navigationItem.rightBarButtonItem = sendItem;
    
    RAC(sendItem, enabled) = [RACSignal combineLatest:@[_feedBackTextView.rac_textSignal]
                                                  reduce:^id(NSString *stringStr){
                                                      return @(stringStr && stringStr.length > 0);
                                                  }];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [_feedBackTextView resignFirstResponder];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

#pragma mark - Action
- (void)sendMessage {
    _feedBackTextView.text = @"";
    //取消聚焦
    [_feedBackTextView resignFirstResponder];
    //等候
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    hub.removeFromSuperViewOnHide = YES;
    hub.labelText = @"正在发送中......";
    [hub show:YES];
    [self.view addSubview:hub];
    @weakify(self);
    [[NetAPIManager shareManager] request_feedBackWithMessage:_feedBackTextView.text andBlock:^(id data, NSError *error) {
        @strongify(self);
        [hub hide:YES];
        if (data) {
            [self showHudTipStr:@"发送成功,感谢您对本公司的意见"];
        }
    }];
}
@end
