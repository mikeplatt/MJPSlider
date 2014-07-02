//
//  MJPSlider.m
//  MJPLineGraph
//
//  Created by Mike Platt on 01/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import "MJPSlider.h"
#import "UIColor+Hex.h"

static CGFloat kSliderTrackWidth = 4.0;
static CGFloat kSliderTrackCornerRadius = 2.0;
static NSString *kSliderTrackColor = @"#F00";

static CGFloat kSliderHandleSize = 20.0;
static CGFloat kSliderHandleCornerRadius = 10.0;
static NSString *kSliderHandleColor = @"#F00";

static CGFloat kSliderDividerTopOffset = 0.0;
static CGFloat kSliderDividerBottomOffset = 10.0;
static NSString *kSliderDividerColor = @"#CCC";

static CGRect kSliderFlagSize = { 0.0, 0.0, 150.0, 60.0 };
static CGFloat kSliderFlagPadding = 30.0;
static CGFloat kSliderFlagCornerRadius = 10.0;
static NSString *kSliderFlagColor = @"#999";

static NSString *kSliderFlagTitleFont = @"Helvetica";
static CGFloat kSliderFlagTitleFontSize = 30.0;
static NSString *kSliderFlagTitleColor = @"#CCC";

static CGFloat kSliderHandlePadding = 20.0;
static CGPoint kSliderTrackCenter;
static CGFloat kSliderMinValue;
static CGFloat kSliderMaxValue;

@interface MJPSlider ()

@property (nonatomic, strong) UIView *track;
@property (nonatomic, strong) UIView *handle;
@property (nonatomic, strong) UIView *flag;
@property (nonatomic, strong) UILabel *flagTitle;


@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation MJPSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor yellowColor];
    
    self.clipsToBounds = NO;
    
    
    kSliderTrackCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    kSliderMinValue = kSliderHandleSize / 2 + kSliderHandlePadding;
    
    kSliderMaxValue = self.frame.size.width - (kSliderHandleSize / 2) - kSliderHandlePadding;
    
    
    _track = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kSliderTrackWidth)];
    
    _track.center = kSliderTrackCenter;
    
    _track.layer.cornerRadius = kSliderTrackCornerRadius;
    
    _track.backgroundColor = [UIColor colorFromHex:kSliderTrackColor];
    
    [self addSubview:_track];
    
    
    _handle = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kSliderHandleSize, kSliderHandleSize)];
    
    _handle.center = kSliderTrackCenter;
    
    _handle.layer.cornerRadius = kSliderHandleCornerRadius;
    
    _handle.backgroundColor = [UIColor colorFromHex:kSliderHandleColor];
    
    [self addSubview:_handle];
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake((kSliderHandleSize / 2) - (kSliderFlagPadding / 2), 0.0 - kSliderFlagPadding + (kSliderHandleSize / 2))];
    
    [path addLineToPoint:CGPointMake((kSliderHandleSize / 2) + (kSliderFlagPadding / 2), 0.0 - kSliderFlagPadding + (kSliderHandleSize / 2))];
    
    [path addLineToPoint:CGPointMake(kSliderHandleSize / 2, 0.0)];
    
    
    CAShapeLayer *triangle = [CAShapeLayer layer];
    
    triangle.path = path.CGPath;
    
    triangle.fillColor = [[UIColor colorFromHex:kSliderFlagColor] CGColor];
    
    [_handle.layer addSublayer:triangle];
    
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
    
    [_handle addGestureRecognizer:_pan];
    
    
    _flag = [[UIView alloc] initWithFrame:kSliderFlagSize];
    
    _flag.center = CGPointMake(kSliderTrackCenter.x, kSliderTrackCenter.y - kSliderFlagPadding - (_flag.frame.size.height / 2));
    
    _flag.backgroundColor = [UIColor colorFromHex:kSliderFlagColor];
    
    _flag.layer.cornerRadius = kSliderFlagCornerRadius;
    
    [self addSubview:_flag];
    
    
    _flagTitle = [[UILabel alloc] initWithFrame:_flag.bounds];
    
    _flagTitle.backgroundColor = [UIColor clearColor];
    
    _flagTitle.font = [UIFont fontWithName:kSliderFlagTitleFont size:kSliderFlagTitleFontSize];
    
    _flagTitle.textColor = [UIColor colorFromHex:kSliderFlagTitleColor];
    
    _flagTitle.textAlignment = NSTextAlignmentCenter;
    
    _flagTitle.text = @"50.00%";
    
    [_flag addSubview:_flagTitle];
}

- (void)dragHandle:(UIPanGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translated = [gesture locationInView:self];
        
        translated.y = kSliderTrackCenter.y;
        
        translated.x = MAX(translated.x, kSliderMinValue);
        
        translated.x = MIN(kSliderMaxValue, translated.x);
        
        _handle.center = translated;
        
        CGFloat percent = [self percentageFromPosition:translated.x];
        
        _flagTitle.text = [[NSString stringWithFormat:@"%.2f", percent] stringByAppendingString:@"%"];
        
        [self.delegate sliderChangedToValue:percent];
        
        translated.y = kSliderTrackCenter.y - kSliderFlagPadding - (_flag.frame.size.height / 2);
        
        translated.x = MAX(translated.x, kSliderFlagSize.size.width / 2);
        
        translated.x = MIN(self.frame.size.width - (kSliderFlagSize.size.width / 2), translated.x);
        
        _flag.center = translated;
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (CGFloat)percentageFromPosition:(CGFloat)position
{
    CGFloat current = position - (kSliderHandleSize / 2) - kSliderHandlePadding;
    
    CGFloat total = self.frame.size.width - kSliderHandleSize - (2 * kSliderHandlePadding);
    
    CGFloat percent = (current / total) * 100.0;
    
    return percent;
}

@end
