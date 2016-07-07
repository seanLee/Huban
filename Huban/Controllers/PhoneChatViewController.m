//
//  PhoneChatViewController.m
//  Huban
//
//  Created by sean on 15/8/26.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kHand_Circle_Width 125.f    //手型图案的边长
#define kTopView_Width 210.f        //整个图案的边长

#import "PhoneChatViewController.h"

@interface PhoneChatViewController ()
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *logoView;
@property (strong, nonatomic) User *curUser;
@end

@implementation PhoneChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"电话对对碰";
    
    //backgroundView
    UIImage *backgroundImage = [UIImage imageNamed:@"phoneChat_back"];
    self.view.layer.contents = (id)backgroundImage.CGImage;
    
    //当前登录用户
    _curUser = [Login curLoginUser];
    //topView
    [self setupTopView];
    //logoView
    [self setupLogoView];
}

- (void)setupTopView {
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64.f)];
    _topView.backgroundColor = [UIColor colorWithWhite:0 alpha:.3f];
    [self.view addSubview:_topView];
    
    CGFloat buttonWidth = 30.f;
    
    UITextField *ageField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth - buttonWidth, CGRectGetHeight(_topView.frame))];
    [ageField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
    ageField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入自己的年龄"
                                                                     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:kBaseFont}];
    ageField.font = kBaseFont;
    ageField.textColor = [UIColor whiteColor];
    [_topView addSubview:ageField];
    
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, CGRectGetHeight(_topView.frame))];
    submitButton.enabled = NO;
    submitButton.titleLabel.font = kBaseFont;
    [submitButton setTitle:@"确定" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor colorWithHexString:@"0x405f8f"] forState:UIControlStateDisabled];
    [_topView addSubview:submitButton];
    
    [ageField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topView).offset(kPaddingLeftWidth);
        make.width.mas_equalTo(kScreen_Width - 2*kPaddingLeftWidth - buttonWidth);
        make.height.mas_equalTo(64);
        make.centerY.equalTo(_topView);
    }];
    
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topView).offset(-kPaddingLeftWidth);
        make.width.mas_equalTo(buttonWidth);
        make.height.mas_equalTo(64);
        make.centerY.equalTo(_topView);
    }];
    
    RAC(submitButton, enabled) = [RACSignal combineLatest:@[RACObserve(self, curUser.userage)]
                                                  reduce:^id(NSNumber *userAge){
                                                      return @(userAge && userAge.intValue > 0);
                                                  }];
}

- (void)setupLogoView {
    _logoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_topView.frame), 210.f, 210.f)];
    UIImage *logo = [UIImage imageNamed:@"phoneChat_Logo"];
    _logoView.layer.contents = (id)logo.CGImage;
    [self.view addSubview:_logoView];
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(logo.size.width);
        make.top.equalTo(_topView.mas_bottom);
        make.centerX.equalTo(self.view);
    }];
    
    CGFloat perDiameter = (logo.size.width - kHand_Circle_Width)/3;
    [self doCircleBorderWithPerDiameter:perDiameter];

}

#pragma mark - Shake Gesture
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"摇动开始");
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"摇动结束");
}

#pragma mark - Action
- (void)textValueChanged:(UITextField *)textField {
    _curUser.userage = @(textField.text.intValue);
}

#pragma mark - Private
- (void)doCircleBorderWithPerDiameter:(CGFloat)perDiameter {
    for (int i = 1; i <= 3; i++) {
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kTopView_Width/2, kTopView_Width/2) radius:(kHand_Circle_Width + i*perDiameter)/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        
        CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
        circleLayer.lineWidth = 1.f;
        circleLayer.fillColor = [UIColor clearColor].CGColor;
        circleLayer.strokeColor = [UIColor redColor].CGColor;
        circleLayer.path = circlePath.CGPath;
        
        
//        CAGradientLayer *circleGradientLayer = [[CAGradientLayer alloc] init];
//        circleGradientLayer.frame = CGRectMake(0, 0, kHand_Circle_Width + i*perDiameter, kHand_Circle_Width + i*perDiameter);
//        circleGradientLayer.locations = [NSArray arrayWithObjects:
//                                         [NSNumber numberWithFloat:0.0],
//                                         [NSNumber numberWithFloat:0.3],
//                                         [NSNumber numberWithFloat:0.8],
//                                         [NSNumber numberWithFloat:1.0],
//                                         nil];
//        circleGradientLayer.colors = [NSArray arrayWithObjects:
//                                      (id)[[[UIColor blackColor] colorWithAlphaComponent:1] CGColor],
//                                      (id)[[[UIColor yellowColor] colorWithAlphaComponent:1] CGColor],
//                                      (id)[[[UIColor blueColor] colorWithAlphaComponent:1] CGColor],
//                                      (id)[[UIColor clearColor] CGColor],
//                                      nil];
//        circleGradientLayer.mask = circleLayer;
//        circleGradientLayer.masksToBounds = YES;
        [_logoView.layer addSublayer:circleLayer];
    }
}
@end
