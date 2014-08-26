//
//  MJPSlider.h
//  MJPSlider
//
//  Created by Mike Platt on 16/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    kSliderStyleSliding,
    kSliderStyleDivided
    
} SliderStyle;

@protocol MJPSliderDelegate;

@interface MJPSlider : UIControl

@property (nonatomic, assign) IBOutlet id<MJPSliderDelegate> delegate;

@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) SliderStyle style;

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, assign) CGFloat trackWidth;

@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, assign) CGFloat highlightPadding;

@property (nonatomic, strong) UIColor *handleColor;
@property (nonatomic, assign) CGFloat handleSize;
@property (nonatomic, assign) CGFloat handlePadding;

@property (nonatomic, assign) CGFloat dividerWidth;
@property (nonatomic, assign) CGFloat dividerPadding;

@property (nonatomic, assign) BOOL showFlag;
@property (nonatomic, strong) UIColor *flagColor;
@property (nonatomic, assign) CGSize flagSize;
@property (nonatomic, assign) CGFloat flagCornerRadius;
@property (nonatomic, assign) CGFloat flagPadding;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) NSString *format;
@property (nonatomic, assign) NSInteger round;


- (void)setDividerPoints:(NSArray *)options;
- (void)slideToValue:(id)value animated:(BOOL)animated;
- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated;
- (CGFloat)percentageFromValue:(CGFloat)value;

@end

@protocol MJPSliderDelegate <NSObject>

@optional
- (void)sliderWillMove:(MJPSlider *)slider;
- (void)sliderDidMove:(MJPSlider *)slider;
- (void)sliderDidFinish:(MJPSlider *)slider;

@end

@interface MJPSliderHandle : UIView

@property (nonatomic, assign) CGRect hitFrame;

@end
