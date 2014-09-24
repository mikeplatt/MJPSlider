//
//  MJPSlider.m
//  MJPSlider
//
//  Created by Mike Platt on 16/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import "MJPSlider.h"

typedef enum {
    
    MJPSliderStyleSliding,
    MJPSliderStyleDivided,
    MJPSliderStyleRangeSliding,
    MJPSliderStyleRangeDivided
    
} MJPSliderStyle;

@interface MJPSlider ()

@property (nonatomic, assign) CGFloat privateLowerValue;
@property (nonatomic, assign) CGFloat privateUpperValue;
@property (nonatomic, assign) NSInteger currentLowerIndex;
@property (nonatomic, assign) NSInteger currentUpperIndex;
@property (nonatomic, assign) CGPoint trackCenter;
@property (nonatomic, assign) CGFloat valueMin;
@property (nonatomic, assign) CGFloat valueMax;
@property (nonatomic, strong) UIView *dividers;
@property (nonatomic, strong) UIView *track;
@property (nonatomic, strong) CALayer *slide;

@property (nonatomic, assign) MJPSliderStyle style;

@property (nonatomic, strong) MJPSliderHandle *lowerHandle;
@property (nonatomic, strong) UIView *lowerFlag;
@property (nonatomic, strong) UILabel *lowerFlagTitle;
@property (nonatomic, strong) CAShapeLayer *lowerTriangle;

@property (nonatomic, strong) MJPSliderHandle *upperHandle;
@property (nonatomic, strong) UIView *upperFlag;
@property (nonatomic, strong) UILabel *upperFlagTitle;
@property (nonatomic, strong) CAShapeLayer *upperTriangle;

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSLayoutConstraint *trackConstraintWidth;
@property (nonatomic, strong) UIColor *lightTrackColor;

@end

@implementation MJPSlider

@synthesize isRangeSlider = _isRangeSlider;
@synthesize trackColor = _trackColor;
@synthesize trackWidth = _trackWidth;
@synthesize highlightPadding = _highlightPadding;
@synthesize handleSize = _handleSize;
@synthesize handlePadding = _handlePadding;
@synthesize dividerWidth = _dividerWidth;
@synthesize dividerPadding = _dividerPadding;
@synthesize showFlag = _showFlag;
@synthesize flagColor = _flagColor;
@synthesize flagSize = _flagSize;
@synthesize flagCornerRadius = _flagCornerRadius;
@synthesize flagPadding = _flagPadding;
@synthesize font = _font;
@synthesize format = _format;
@synthesize textColor = _textColor;
@synthesize minValue = _minValue;
@synthesize maxValue = _maxValue;

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self defaultValues];
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self defaultValues];
        [self commonInit];
    }
    return self;
}

- (void)defaultValues
{
    self.trackColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.trackWidth = 2.0;
    self.highlightPadding = 0.0;
    self.handleSize = 26.0;
    self.handlePadding = 11.0;
    self.dividerWidth = 1.0;
    self.dividerPadding = 5.0;
    self.showFlag = YES;
    self.flagColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.flagSize = CGSizeMake(160.0, 30.0);
    self.flagCornerRadius = 2.0;
    self.flagPadding = 16.0;
    self.font = [UIFont systemFontOfSize:14.0];
    self.textColor = [UIColor darkGrayColor];
    self.minValue = 0.0;
    self.maxValue = 100.0;
    self.animationDuration = 0.2;
    self.format = @"%.2f";
}


- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    
    _trackCenter = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self calculateMinMax];
    
    _track = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.trackWidth)];
    _track.backgroundColor = self.trackColor;
    _track.center = _trackCenter;
    _track.layer.cornerRadius = self.trackWidth / 2;
    _track.layer.masksToBounds = YES;
    [self addSubview:_track];
    [self setConstraintsForTrack];
    
    CGRect slideFrame = _track.bounds;
    slideFrame.size.width = _track.bounds.size.width / 2;
    _slide = [CALayer layer];
    _slide.frame = slideFrame;
    _slide.backgroundColor = self.tintColor.CGColor;
    [_track.layer addSublayer:_slide];
    
    _dividers = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.trackWidth - (2 * self.dividerPadding))];
    _dividers.center = _trackCenter;
    [self addSubview:_dividers];
    
    _lowerHandle = [[MJPSliderHandle alloc] initWithFrame:CGRectMake(0.0, 0.0, self.handleSize, self.handleSize)];
    _lowerHandle.backgroundColor = [UIColor whiteColor];
    _lowerHandle.center = _trackCenter;
    _lowerHandle.layer.cornerRadius = self.handleSize / 2;
    [self addSubview:_lowerHandle];
    
    _lowerTriangle = [CAShapeLayer layer];
    _lowerTriangle.path = [self pathForFlag].CGPath;
    _lowerTriangle.fillColor = [self.flagColor CGColor];
    [_lowerHandle.layer addSublayer:_lowerTriangle];
    
    _lowerFlag = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.flagSize.width, self.flagSize.height)];
    _lowerFlag.center = CGPointMake(_trackCenter.x, _trackCenter.y - (self.handleSize / 2) - self.flagPadding - (_lowerFlag.frame.size.height / 2));
    _lowerFlag.layer.cornerRadius = self.flagCornerRadius;
    _lowerFlag.backgroundColor = self.flagColor;
    [self addSubview:_lowerFlag];
    
    _lowerFlagTitle = [[UILabel alloc] initWithFrame:_lowerFlag.bounds];
    _lowerFlagTitle.font = self.font;
    _lowerFlagTitle.textColor = self.textColor;
    _lowerFlagTitle.textAlignment = NSTextAlignmentCenter;
    _lowerFlagTitle.text = [NSString stringWithFormat:self.format, _privateLowerValue];
    [_lowerFlag addSubview:_lowerFlagTitle];
    
    UIPanGestureRecognizer *lowerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
    [_lowerHandle addGestureRecognizer:lowerPan];
    
    
    _upperHandle = [[MJPSliderHandle alloc] initWithFrame:CGRectMake(0.0, 0.0, self.handleSize, self.handleSize)];
    _upperHandle.backgroundColor = [UIColor whiteColor];
    _upperHandle.center = _trackCenter;
    _upperHandle.layer.cornerRadius = self.handleSize / 2;
    _upperHandle.hidden = YES;
    [self addSubview:_upperHandle];
    
    _upperTriangle = [CAShapeLayer layer];
    _upperTriangle.path = [self pathForFlag].CGPath;
    _upperTriangle.fillColor = [self.flagColor CGColor];
    _upperHandle.hidden = YES;
    [_upperHandle.layer addSublayer:_upperTriangle];
    
    _upperFlag = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.flagSize.width, self.flagSize.height)];
    _upperFlag.center = CGPointMake(_trackCenter.x, _trackCenter.y - (self.handleSize / 2) - self.flagPadding - (_upperFlag.frame.size.height / 2));
    _upperFlag.layer.cornerRadius = self.flagCornerRadius;
    _upperFlag.backgroundColor = self.flagColor;
    _upperFlag.hidden = YES;
    [self addSubview:_upperFlag];
    
    _upperFlagTitle = [[UILabel alloc] initWithFrame:_upperFlag.bounds];
    _upperFlagTitle.font = self.font;
    _upperFlagTitle.textColor = self.textColor;
    _upperFlagTitle.textAlignment = NSTextAlignmentCenter;
    _upperFlagTitle.text = [NSString stringWithFormat:self.format, _privateLowerValue];
    [_upperFlag addSubview:_upperFlagTitle];
    
    UIPanGestureRecognizer *upperPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
    [_upperHandle addGestureRecognizer:upperPan];
}

#pragma mark - Public

- (void)setDividerPoints:(NSArray *)options
{
    if(options) {
        
        self.style = MJPSliderStyleDivided;
        self.format = @"%@ - %.2f";
        
        for(UIView * subview in _dividers.subviews) {
            [subview removeFromSuperview];
        }
        
        _titles = [NSMutableArray new];
        _values = [NSMutableArray new];
        _points = [NSMutableArray new];
        
        CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding) - self.dividerWidth;
        CGFloat gap = total / (options.count - 1);
        CGFloat theX = (self.handleSize / 2) + self.handlePadding;
        CGFloat height = _dividers.frame.size.height;
        
        for(int i = 0; i < options.count; i++) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(theX, 0.0, self.dividerWidth, height)];
            view.backgroundColor = self.tintColor;
            view.layer.cornerRadius = self.dividerWidth / 2;
            [_dividers addSubview:view];
            NSDictionary *option = options[i];
            [_titles addObject:option[@"title"]];
            [_values addObject:option[@"value"]];
            [_points addObject:[NSNumber numberWithFloat:view.center.x]];
            theX += gap;
        }
        
    } else {
        
        self.style = MJPSliderStyleSliding;
        
        _titles = nil;
        _values = nil;
        _points = nil;

        for(UIView * subview in _dividers.subviews) {
            [subview removeFromSuperview];
        }
    }
}

- (void)updateDividers
{
    NSLog(@"HIT THIS");
    _points = [NSMutableArray new];
    
    CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding) - self.dividerWidth;
    CGFloat gap = total / (_titles.count - 1);
    CGFloat theX = (self.handleSize / 2) + self.handlePadding;
    CGFloat height = _dividers.bounds.size.height;
    
    for(UIView * subview in _dividers.subviews) {
        
        subview.frame = CGRectMake(theX, 0.0, self.dividerWidth, height);
        subview.backgroundColor = self.tintColor;
        subview.layer.cornerRadius = self.dividerWidth / 2;
        [_points addObject:[NSNumber numberWithFloat:subview.center.x]];
        theX += gap;
    }
    
    [self setLowerValue:_currentLowerIndex andUpperValue:_currentUpperIndex animated:NO];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated
{
    [self setLowerValue:value andUpperValue:0.0 animated:animated];
}

- (void)setLowerValue:(CGFloat)lowerValue andUpperValue:(CGFloat)upperValue animated:(BOOL)animated
{
    CGPoint newLowerHandle;
    CGPoint newUpperHandle;
    
    if(self.style == MJPSliderStyleSliding || self.style == MJPSliderStyleRangeSliding) {
        
        _privateLowerValue = lowerValue;
        _privateLowerValue = (_privateLowerValue < self.minValue) ? self.minValue : _privateLowerValue;
        _privateLowerValue = (_privateLowerValue > self.maxValue) ? self.maxValue : _privateLowerValue;
        newLowerHandle =  CGPointMake([self positionFromValue:_privateLowerValue], _track.center.y);
        _lowerFlagTitle.text = [NSString stringWithFormat:self.format, _privateLowerValue];
        
        _privateUpperValue = upperValue;
        _privateUpperValue = (_privateUpperValue < self.minValue) ? self.minValue : _privateUpperValue;
        _privateUpperValue = (_privateUpperValue > self.maxValue) ? self.maxValue : _privateUpperValue;
        newUpperHandle =  CGPointMake([self positionFromValue:_privateUpperValue], _track.center.y);
        _upperFlagTitle.text = [NSString stringWithFormat:self.format, _privateUpperValue];
        
    } else {
        
        _currentLowerIndex = lowerValue;
        newLowerHandle = CGPointMake([_points[_currentLowerIndex] floatValue], _track.center.y);
        NSString *lowerTitle = _titles[_currentLowerIndex];
        _privateLowerValue = [_values[_currentLowerIndex] floatValue];
        _lowerFlagTitle.text = [NSString stringWithFormat:self.format, lowerTitle, _privateLowerValue];
        
        _currentUpperIndex = upperValue; NSLog(@"%ld", _currentUpperIndex);
        newUpperHandle = CGPointMake([_points[_currentUpperIndex] floatValue], _track.center.y);
        NSString *upperTitle = _titles[_currentUpperIndex];
        _privateUpperValue = [_values[_currentUpperIndex] floatValue];
        _upperFlagTitle.text = [NSString stringWithFormat:self.format, upperTitle, _privateUpperValue];
    }
    
    CGFloat constrainLeft = self.flagSize.width / 2;
    CGFloat constrainRight = self.frame.size.width - (self.flagSize.width / 2);
    
    CGFloat lowerFlagPosition = newLowerHandle.x;
    lowerFlagPosition = MAX(constrainLeft, lowerFlagPosition);
    lowerFlagPosition = MIN(lowerFlagPosition, constrainRight);
    CGPoint newLowerFlag = CGPointMake(lowerFlagPosition, _lowerFlag.center.y);
    
    CGFloat upperFlagPosition = newUpperHandle.x;
    upperFlagPosition = MAX(constrainLeft, upperFlagPosition);
    upperFlagPosition = MIN(upperFlagPosition, constrainRight);
    CGPoint newUpperFlag = CGPointMake(upperFlagPosition, _upperFlag.center.y);
    
    CGRect slideFrame = _slide.frame;
    if(self.isRangeSlider) {
        slideFrame.origin.x = newLowerHandle.x;
        slideFrame.size.width = newUpperHandle.x - newLowerHandle.x;
    } else {
        slideFrame.size.width = newLowerHandle.x;
    }
    
    if(animated) {
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             _lowerHandle.center = newLowerHandle;
                             _lowerFlag.center = newLowerFlag;
                             _upperHandle.center = newUpperHandle;
                             _upperFlag.center = newUpperFlag;
                             _slide.frame = slideFrame;
                         } completion:nil];
    } else {
        _lowerHandle.center = newLowerHandle;
        _lowerFlag.center = newLowerFlag;
        _upperHandle.center = newUpperHandle;
        _upperFlag.center = newUpperFlag;
        _slide.frame = slideFrame;
    }
}

#pragma mark - Private

- (void)calculateMinMax
{
    _valueMin = (self.handleSize / 2) + self.handlePadding;
    _valueMax = self.frame.size.width - (self.handleSize / 2) - self.handlePadding;
}

- (UIBezierPath *)pathForFlag
{
    CGFloat point = (self.trackWidth > self.handleSize) ? (self.handleSize - self.trackWidth) / 2 : 0.0;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, 0.0 - self.flagPadding)];
    [path addLineToPoint:CGPointMake(self.handleSize, 0.0 - self.flagPadding)];
    [path addLineToPoint:CGPointMake(self.handleSize / 2, point)];
    return path;
}

- (void)dragHandle:(UIPanGestureRecognizer *)gesture
{
    BOOL isLowerHandle = (gesture.view == _lowerHandle) ? YES : NO;
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        if([self.delegate respondsToSelector:@selector(sliderWillMove:)]) {
            [self.delegate sliderWillMove:self];
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translated = [gesture locationInView:self];
        translated.y = _trackCenter.y;
        
        if(self.style == MJPSliderStyleSliding || self.style == MJPSliderStyleRangeSliding) {
            
            if(isLowerHandle && self.isRangeSlider) {
                CGFloat minDistance = [self sizeOfMinRange];
                translated.x = MAX(translated.x, _valueMin);
                translated.x = MIN(_upperHandle.center.x - minDistance, translated.x);
            } else if(!isLowerHandle) {
                CGFloat minDistance = [self sizeOfMinRange];
                translated.x = MAX(translated.x, _lowerHandle.center.x + minDistance);
                translated.x = MIN(_valueMax, translated.x);
            } else {
                translated.x = MAX(translated.x, _valueMin);
                translated.x = MIN(_valueMax, translated.x);
            }
        
            gesture.view.center = translated;
            _privateLowerValue = (isLowerHandle) ? [self valueFromPosition:translated.x] : _privateLowerValue;
            _privateUpperValue = (isLowerHandle) ? _privateUpperValue : [self valueFromPosition:translated.x];
            
            if(self.round > 0 && isLowerHandle) {
                _privateLowerValue = round(_privateLowerValue / self.round) * self.round;
            }
            if(self.round > 0 && !isLowerHandle) {
                _privateUpperValue = round(_privateUpperValue / self.round) * self.round;
            }
            
            if(isLowerHandle) {
                _lowerFlagTitle.text = [NSString stringWithFormat:self.format, _privateLowerValue];
                [self setSliderWidthToMeetPointLowerHandleAtPoint:translated animated:NO];
            } else {
                _upperFlagTitle.text = [NSString stringWithFormat:self.format, _privateUpperValue];
                [self setSliderWidthToMeetPointUpperHandleAtPoint:translated animated:NO];
            }
        
            if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                [self.delegate sliderDidMove:self];
            }
            
        } else {
            
            NSInteger before = (isLowerHandle) ?  _currentLowerIndex : _currentUpperIndex;
            CGPoint velocity = [gesture velocityInView:self];
            CGPoint nearest = [self nearestPointToValue:translated.x forLowerHandle:isLowerHandle];
            
            if(velocity.x > 500.0 || velocity.x < -500.0) {
            
                gesture.view.center = nearest;
                
                if(isLowerHandle) {
                    [self setSliderWidthToMeetPointLowerHandleAtPoint:nearest animated:NO];
                } else {
                    [self setSliderWidthToMeetPointUpperHandleAtPoint:nearest animated:NO];
                }
                
                if(isLowerHandle && before != _currentLowerIndex) {
                    _privateLowerValue = (isLowerHandle) ? [_values[_currentLowerIndex] floatValue] : _privateLowerValue;
                    
                    NSString *lowerTitle = _titles[_currentLowerIndex];
                    _lowerFlagTitle.text = [NSString stringWithFormat:self.format, lowerTitle, _privateLowerValue];
                    
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        [self.delegate sliderDidMove:self];
                    }
                }
                
                if(!isLowerHandle && before != _currentUpperIndex) {
                    _privateUpperValue = (isLowerHandle) ? _privateUpperValue : [_values[_currentUpperIndex] floatValue];
                    
                    NSString *upperTitle = _titles[_currentUpperIndex];
                    _upperFlagTitle.text = [NSString stringWithFormat:self.format, upperTitle, _privateUpperValue];
                    
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        [self.delegate sliderDidMove:self];
                    }
                }
                
            } else {
            
                if(isLowerHandle && before != _currentLowerIndex) {
                    
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         _lowerHandle.center = nearest;
                                     }];
                    [self setSliderWidthToMeetPointLowerHandleAtPoint:nearest animated:YES];
                    
                    _privateLowerValue = (isLowerHandle) ? [_values[_currentLowerIndex] floatValue] : _privateLowerValue;
                    
                    NSString *lowerTitle = _titles[_currentLowerIndex];
                    _lowerFlagTitle.text = [NSString stringWithFormat:self.format, lowerTitle, _privateLowerValue];
            
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        [self.delegate sliderDidMove:self];
                    }
                }
                
                if(!isLowerHandle && before != _currentUpperIndex) {
                    
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         _upperHandle.center = nearest;
                                     }];
                    [self setSliderWidthToMeetPointUpperHandleAtPoint:nearest animated:YES];
                    
                    _privateUpperValue = (isLowerHandle) ? _privateUpperValue : [_values[_currentLowerIndex] floatValue];
                    
                    NSString *upperTitle = _titles[_currentUpperIndex];
                    _upperFlagTitle.text = [NSString stringWithFormat:self.format, upperTitle, _privateUpperValue];
                    
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        [self.delegate sliderDidMove:self];
                    }
                }
            }
        }
        
        translated.y = (isLowerHandle) ? _lowerFlag.center.y : _upperFlag.center.y;
        if(isLowerHandle && self.isRangeSlider) {
            translated.x = MAX(translated.x, (self.flagSize.width / 2));
            translated.x = MIN(self.frame.size.width - (self.flagSize.width * 1.5), translated.x);
        } else if(!isLowerHandle) {
            translated.x = MAX(translated.x, (self.flagSize.width * 1.5));
            translated.x = MIN(self.frame.size.width - (self.flagSize.width / 2), translated.x);
        } else {
            translated.x = MAX(translated.x, self.flagSize.width / 2);
            translated.x = MIN(self.frame.size.width - (self.flagSize.width / 2), translated.x);
        }
        if(isLowerHandle) {
            _lowerFlag.center = translated;
        } else {
            _upperFlag.center = translated;
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded) {
        
        if(self.style == MJPSliderStyleSliding || self.style == MJPSliderStyleRangeSliding) {
            _privateLowerValue = (isLowerHandle) ? [self valueFromPosition:_lowerHandle.center.x] : _privateLowerValue;
            _privateUpperValue = (isLowerHandle) ? _privateUpperValue : [self valueFromPosition:_upperHandle.center.x];
            
            if(self.round > 0 && isLowerHandle) {
                _privateLowerValue = round(_privateLowerValue / self.round) * self.round;
            }
            if(self.round > 0 && !isLowerHandle) {
                _privateUpperValue = round(_privateUpperValue / self.round) * self.round;
            }
            
        } else {
            
            _privateLowerValue = (isLowerHandle) ? [_values[_currentLowerIndex] floatValue] : _privateLowerValue;
            _privateUpperValue = (isLowerHandle) ? _privateUpperValue : [_values[_currentLowerIndex] floatValue];
        }
        
        if([self.delegate respondsToSelector:@selector(sliderDidFinish:)]) {
            
            [self.delegate sliderDidFinish:self];
        }
    }
}

- (void)setSliderWidthToMeetPointLowerHandleAtPoint:(CGPoint)point animated:(BOOL)animated
{
    CGRect slideFrame = _slide.frame;
    if(self.isRangeSlider) {
        slideFrame.origin.x = point.x;
        slideFrame.size.width = _upperHandle.center.x - point.x;
    } else {
        slideFrame.size.width = point.x;
    }
    
    if(animated) {
        
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             _slide.frame = slideFrame;
                         }];
        
    } else {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _slide.frame = slideFrame;
        [CATransaction commit];
    }
}

- (void)setSliderWidthToMeetPointUpperHandleAtPoint:(CGPoint)point animated:(BOOL)animated
{
    CGRect slideFrame = _slide.frame;
    slideFrame.size.width = point.x - _lowerHandle.center.x;
    if(animated) {
        
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             _slide.frame = slideFrame;
                         }];
        
    } else {
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _slide.frame = slideFrame;
        [CATransaction commit];
    }
}

#pragma mark - Auto Layout

- (void)setConstraintsForTrack
{
    _track.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_track
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_track
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_track
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    _trackConstraintWidth = [NSLayoutConstraint constraintWithItem:_track
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0
                                                          constant:self.trackWidth];
    
    [self addConstraint:_trackConstraintWidth];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculateMinMax];
    if(_style == MJPSliderStyleDivided || _style == MJPSliderStyleRangeDivided) {
        [self updateDividers];
    } else {
        [self setLowerValue:_privateLowerValue andUpperValue:_privateUpperValue animated:YES];
    }
}

#pragma mark - Value

- (CGFloat)percentageFromPosition:(CGFloat)position
{
    CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding);
    CGFloat current = position - (self.handleSize / 2) - self.handlePadding;
    CGFloat percent = (current / total) * 100.0;
    return percent;
}

- (CGFloat)valueFromPercentage:(CGFloat)percentage
{
    CGFloat total = self.maxValue - self.minValue;
    CGFloat value = ((total / 100.0) * percentage) + self.minValue;
    return value;
}

- (CGFloat)valueFromPosition:(CGFloat)position
{
    CGFloat percent = [self percentageFromPosition:position];
    CGFloat value = [self valueFromPercentage:percent];
    return value;
}

#pragma mark - Position

- (CGFloat)percentageFromValue:(CGFloat)value
{
    CGFloat total = self.maxValue - self.minValue;
    CGFloat adjust = value - self.minValue;
    CGFloat percent = adjust / (total / 100);
    return percent;
}

- (CGFloat)positionFromPercentage:(CGFloat)percentage
{
    CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding);
    return ((total / 100) * percentage) + (self.handleSize / 2) + self.handlePadding;
}

- (CGFloat)positionFromValue:(CGFloat)value
{
    CGFloat percent = [self percentageFromValue:value];
    return [self positionFromPercentage:percent];
}

- (CGFloat)sizeOfMinRange
{
    CGFloat total = self.maxValue - self.minValue;
    CGFloat percent = self.minRange / (total / 100.0);
    CGFloat distance = self.frame.size.width - self.handleSize - (2 * self.handlePadding);
    return ((distance / 100) * percent);
}


#pragma mark - Nearest

- (CGPoint)nearestPointToValue:(CGFloat)value forLowerHandle:(BOOL)lowerHandle
{
    NSUInteger index = [_points indexOfObject:@(value)
                                inSortedRange:NSMakeRange(0, _points.count)
                                      options:NSBinarySearchingFirstEqual | NSBinarySearchingInsertionIndex
                              usingComparator:^(id a, id b) {
                                  
                                  return [a compare:b];
                                  
                              }];
    
    if(index != 0 && index != _points.count) {
        CGFloat leftDifference = value - [_points[index - 1] floatValue];
        CGFloat rightDifference = [_points[index] floatValue] - value;
        if (leftDifference < rightDifference) {
            --index;
        }
    }
    index = MIN(_points.count - 1, index);
    index = MAX(index, 0);
    if(lowerHandle) {
        index = MIN(_currentUpperIndex - self.minRange, index);
       _currentLowerIndex = index;
    } else {
        index = MAX(index, _currentLowerIndex + self.minRange);
        _currentUpperIndex = index;
    }
    CGFloat pointX = [_points[index] floatValue];
    return CGPointMake(pointX, _trackCenter.y);
}


#pragma mark - Getters

- (CGFloat)value
{
    return _privateLowerValue;
}

- (CGFloat)lowerValue
{
    return _privateLowerValue;
}

- (CGFloat)upperValue
{
    return _privateUpperValue;
}


#pragma mark - Setters

- (void)setIsRangeSlider:(BOOL)isRangeSlider
{
    _isRangeSlider = isRangeSlider;
    _upperHandle.hidden = !isRangeSlider;
    if(self.showFlag) {
        _upperFlag.hidden = !isRangeSlider;
        _upperTriangle.hidden = !isRangeSlider;
    }
    
    if(isRangeSlider && _style == MJPSliderStyleSliding) {
        self.style = MJPSliderStyleRangeSliding;
    } else if(isRangeSlider && _style == MJPSliderStyleDivided) {
        self.style = MJPSliderStyleRangeDivided;
    } else if(!isRangeSlider && _style == MJPSliderStyleRangeSliding) {
        self.style = MJPSliderStyleSliding;
    } else if(!isRangeSlider && _style == MJPSliderStyleRangeDivided) {
        self.style = MJPSliderStyleDivided;
    }
}

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    _track.backgroundColor = trackColor;
    _lightTrackColor = [trackColor colorWithAlphaComponent:0.6];
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    _slide.backgroundColor = tintColor.CGColor;
}

- (void)setTrackWidth:(CGFloat)trackWidth
{
    _trackWidth = trackWidth;
    _trackConstraintWidth.constant = trackWidth;
    [_track setNeedsUpdateConstraints];
    [_track layoutIfNeeded];
    _track.layer.cornerRadius = trackWidth / 2;
    _dividers.bounds = CGRectMake(0.0, 0.0, self.frame.size.width, trackWidth + (2 * self.dividerPadding));
    _lowerTriangle.path = [self pathForFlag].CGPath;
    _upperTriangle.path = [self pathForFlag].CGPath;
    if(_titles.count > 0) {
        [self updateDividers];
    }
    _slide.frame = CGRectMake(0.0, 0.0, _slide.bounds.size.width, trackWidth);
}

- (void)setHighlightPadding:(CGFloat)highlightPadding
{
    _highlightPadding = highlightPadding;
    _track.layer.borderWidth = highlightPadding;
    _track.layer.borderColor = self.trackColor.CGColor;
    _track.backgroundColor = _lightTrackColor;
}

- (void)setHandleSize:(CGFloat)handleSize
{
    CGFloat original = _handleSize;
    _handleSize = handleSize;
    
    _lowerHandle.bounds = CGRectMake(0.0, 0.0, handleSize, handleSize);
    _lowerHandle.layer.cornerRadius = handleSize / 2;
    CGPoint lowerFlagCenter = _lowerFlag.center;
    lowerFlagCenter.y -= (handleSize / 2) - (original / 2);
    _lowerFlag.center = lowerFlagCenter;
    _lowerTriangle.path = [self pathForFlag].CGPath;
   
    _upperHandle.bounds = CGRectMake(0.0, 0.0, handleSize, handleSize);
    _upperHandle.layer.cornerRadius = handleSize / 2;
    CGPoint upperFlagCenter = _upperFlag.center;
    upperFlagCenter.y -= (handleSize / 2) - (original / 2);
    _upperFlag.center = upperFlagCenter;
    _upperTriangle.path = [self pathForFlag].CGPath;
    
    [self calculateMinMax];
}

- (void)setHandlePadding:(CGFloat)handlePadding
{
    _handlePadding = handlePadding;
    [self calculateMinMax];
    if(self.style == MJPSliderStyleDivided && _titles.count > 0) {
        
        [self updateDividers];
    }
}

- (void)setDividerWidth:(CGFloat)dividerWidth
{
    _dividerWidth = dividerWidth;
    if(self.style == MJPSliderStyleDivided && _titles.count > 0) {
        [self updateDividers];
    }
}

- (void)setDividerPadding:(CGFloat)dividerPadding
{
    _dividerPadding = dividerPadding;
    _dividers.bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.trackWidth + (2 * dividerPadding));
    _dividers.center = _trackCenter;
    if((self.style == MJPSliderStyleDivided || self.style == MJPSliderStyleRangeDivided) && _titles.count > 0) {
        [self updateDividers];
    }
}

- (void)setShowFlag:(BOOL)showFlag
{
    _showFlag = showFlag;
    _lowerFlag.hidden = !showFlag;
    _upperFlag.hidden = !showFlag;
    _lowerTriangle.hidden = !showFlag;
    _upperTriangle.hidden = !showFlag;
}

- (void)setFlagColor:(UIColor *)flagColor
{
    _flagColor = flagColor;
    _lowerFlag.backgroundColor = flagColor;
    _upperFlag.backgroundColor = flagColor;
    _lowerTriangle.fillColor = flagColor.CGColor;
    _upperTriangle.fillColor = flagColor.CGColor;
}

- (void)setFlagSize:(CGSize)flagSize
{
    CGFloat difference = (_flagSize.height - flagSize.height) / 2;
    _flagSize = flagSize;
    
    _lowerFlag.bounds = CGRectMake(0.0, 0.0, flagSize.width, flagSize.height);
    _lowerFlag.center = CGPointMake(_lowerFlag.center.x, _lowerFlag.center.y + difference);
    _lowerFlagTitle.frame = _lowerFlag.bounds;
    
    _upperFlag.bounds = CGRectMake(0.0, 0.0, flagSize.width, flagSize.height);
    _upperFlag.center = CGPointMake(_upperFlag.center.x, _upperFlag.center.y + difference);
    _upperFlagTitle.frame = _upperFlag.bounds;
}

- (void)setFlagCornerRadius:(CGFloat)flagCornerRadius
{
    _flagCornerRadius = flagCornerRadius;
    _lowerFlag.layer.cornerRadius = flagCornerRadius;
    _upperFlag.layer.cornerRadius = flagCornerRadius;
}

- (void)setFlagPadding:(CGFloat)flagPadding
{
    CGFloat difference = self.flagPadding - flagPadding;
    _flagPadding = flagPadding;
    _lowerFlag.center = CGPointMake(_lowerFlag.center.x, _lowerFlag.center.y + difference);
    _lowerTriangle.path = [self pathForFlag].CGPath;
    _upperFlag.center = CGPointMake(_upperFlag.center.x, _upperFlag.center.y + difference);
    _upperTriangle.path = [self pathForFlag].CGPath;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    _lowerFlagTitle.font = font;
    _upperFlagTitle.font = font;
}

- (void)setFormat:(NSString *)format
{
    _format = format;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _lowerFlagTitle.textColor = textColor;
    _upperFlagTitle.textColor = textColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [self setEnabled:enabled animated:NO];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated
{
    [super setEnabled:enabled];
    self.userInteractionEnabled = enabled;
    CGFloat alpha = (enabled) ? 1.0 : 0.5;
    
    if(animated) {
        
        [UIView animateWithDuration:0.4 animations:^{
            self.alpha = alpha;
        }];
    }
}

@end



@implementation MJPSliderHandle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGFloat width = frame.size.width;
        if(width < 50.0) {
            CGFloat offset = (50.0 - width) / 2;
            self.hitFrame = CGRectMake(0 - offset, 0 - offset, 50.0, 50.0);
        } else {
            self.hitFrame = frame;
        }
        self.layer.shadowPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOffset = CGSizeMake(-1.0, 2.0);
        self.layer.shadowOpacity = 0.1;
        self.layer.masksToBounds = NO;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.hitFrame, point);
}

@end