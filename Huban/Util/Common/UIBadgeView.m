//
//  UIBadgeView.m
//  Huban
//
//  Created by sean on 15/7/24.
//  Copyright (c) 2015年 sean. All rights reserved.
//

#define kMaxBadgeWith 100.0
#define kBadgeTextOffset 2.0
#define kBadgePading 2.0
#define kBadgeTextFont  [UIFont systemFontOfSize:12]

#import "UIBadgeView.h"

@interface UIBadgeView ()
@property (strong) UIColor *badgeBackgroundColor;
@property (strong) UIColor *badgeTextColor;
@property (nonatomic) UIFont *badgeTextFont;
@end

@implementation UIBadgeView
+ (UIBadgeView *)viewWithBadgeTip:(NSString *)badgeValue {
    if (!badgeValue || badgeValue.length == 0) {
        return nil;
    }
    UIBadgeView *badgeView = [[UIBadgeView alloc] init];
    badgeView.frame = [badgeView badgeFrameWithStr:badgeValue];
    badgeView.badgeValue = badgeValue;
    return badgeView;
}

+ (CGSize)badgeSizeWithStr:(NSString *)badgeValue font:(UIFont *)font {
    if (!badgeValue || badgeValue.length == 0) {
        return CGSizeZero;
    }
    if (!font) {
        font = kBadgeTextFont;
    }
    CGSize badgeSize = [badgeValue getSizeWithFont:font constrainedToSize:CGSizeMake(kMaxBadgeWith, 20.f)];
    
    if (badgeSize.width < badgeSize.height) {
        badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
    }
    if ([badgeValue isEqualToString:kBadgeTipStr]) {
        badgeSize = CGSizeMake(4.f, 4.f);
    }
    return badgeSize;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    self.backgroundColor = [UIColor clearColor];
    _badgeBackgroundColor = [UIColor colorWithHexString:@"0xe1272f"];
    _badgeTextColor = [UIColor whiteColor];
    _badgeTextFont = [UIFont systemFontOfSize:12.f];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    //drawing code
    //draw badges
    if ([[self badgeValue] length]) {
        CGSize badgeSize = [self badgeSizeWithStr:_badgeValue];
        
        CGRect badgeBackgroundFrame = CGRectMake(kBadgeTextOffset, kBadgeTextOffset,
                                               badgeSize.width + 2*kBadgeTextOffset, badgeSize.height + 2*kBadgeTextOffset);
//        CGRect badgeBackgroundPaddingFrame = CGRectMake(0, 0, badgeBackgroundFrame.size.width + 2*kBadgePading, badgeBackgroundFrame.size.height +2*kBadgePading);
        
        if ([self badgeBackgroundColor]) {
            if (![self.badgeValue isEqualToString:kBadgeTipStr]){//外白色秒边
//                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//                
//                if (badgeSize.width > badgeSize.height) {
//                    CGFloat circleWidth = badgeBackgroundPaddingFrame.size.height;
//                    CGFloat totalWidth = badgeBackgroundPaddingFrame.size.width;
//                    CGFloat diffWidth = totalWidth - circleWidth;
//                    CGPoint originPoint = badgeBackgroundPaddingFrame.origin;
//                    
//                    CGRect leftCircleFrame = CGRectMake(originPoint.x, originPoint.y, circleWidth, circleWidth);
//                    CGRect centerFrame = CGRectMake(originPoint.x + circleWidth/2, originPoint.y + circleWidth/2, diffWidth, circleWidth);
//                    CGRect rightCirCleFrame = CGRectMake(originPoint.x + (totalWidth - circleWidth), originPoint.y, circleWidth, circleWidth);
//                    CGContextFillEllipseInRect(context, leftCircleFrame);
//                    CGContextFillRect(context, centerFrame);
//                    CGContextFillEllipseInRect(context, rightCirCleFrame);
//                } else {
//                    CGContextFillEllipseInRect(context, badgeBackgroundPaddingFrame);
//                }
            }
            //badge背景色
            CGContextSetFillColorWithColor(context, [self badgeBackgroundColor].CGColor);
            if (badgeSize.width > badgeSize.height) {
                CGFloat circleWith = badgeBackgroundFrame.size.height;
                CGFloat totalWidth = badgeBackgroundFrame.size.width;
                CGFloat diffWidth = totalWidth - circleWith;
                CGPoint originPoint = badgeBackgroundFrame.origin;
                
                
                CGRect leftCicleFrame = CGRectMake(originPoint.x, originPoint.y, circleWith, circleWith);
                CGRect centerFrame = CGRectMake(originPoint.x +circleWith/2, originPoint.y, diffWidth, circleWith);
                CGRect rightCicleFrame = CGRectMake(originPoint.x +(totalWidth - circleWith), originPoint.y, circleWith, circleWith);
                CGContextFillEllipseInRect(context, leftCicleFrame);
                CGContextFillRect(context, centerFrame);
                CGContextFillEllipseInRect(context, rightCicleFrame);
            } else {
                CGContextFillEllipseInRect(context, badgeBackgroundFrame);
            }
        }
        CGContextSetFillColorWithColor(context, [self badgeTextColor].CGColor);
        
        NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [badgeTextStyle setAlignment:NSTextAlignmentCenter];
        NSDictionary *badgeTextAttributes = @{NSFontAttributeName:[self badgeTextFont],
                                              NSForegroundColorAttributeName:[self badgeTextColor],
                                              NSParagraphStyleAttributeName:badgeTextStyle};
        [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame) + kBadgeTextOffset,
                                                 CGRectGetMinY(badgeBackgroundFrame) + kBadgeTextOffset,
                                                 badgeSize.width, badgeSize.height)
                       withAttributes:badgeTextAttributes];
    }
    CGContextRestoreGState(context);
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    self.frame = [self badgeFrameWithStr:badgeValue];
    [self setNeedsDisplay];
}

- (CGSize)badgeSizeWithStr:(NSString *)badgeValue {
    return [UIBadgeView badgeSizeWithStr:badgeValue font:self.badgeTextFont];
}

- (CGRect)badgeFrameWithStr:(NSString *)badgeValue {
    CGSize badgeSize = [self badgeSizeWithStr:badgeValue];
    CGRect badgeFrame = CGRectMake(0, 0, badgeSize.width + 8.f, badgeSize.height + 8.f);
    return badgeFrame;
}
@end
