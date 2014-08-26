//
//  MJPSlider.m
//  MJPSlider
//
//  Created by Mike Platt on 16/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import "MJPSlider.h"

@interface MJPSlider ()

@property (nonatomic, assign) CGPoint trackCenter;
@property (nonatomic, assign) CGFloat valueMin;
@property (nonatomic, assign) CGFloat valueMax;
@property (nonatomic, strong) UIView *dividers;
@property (nonatomic, strong) UIView *track;
@property (nonatomic, strong) CALayer *slide;
@property (nonatomic, strong) MJPSliderHandle *handle;
@property (nonatomic, strong) UIView *flag;
@property (nonatomic, strong) CAShapeLayer *triangle;
@property (nonatomic, strong) UILabel *flagTitle;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;
@property (nonatomic, strong) NSLayoutConstraint *trackConstraintWidth;
@property (nonatomic, strong) UIColor *lightTrackColor;

@end

@implementation MJPSlider

@synthesize trackColor = _trackColor;
@synthesize trackWidth = _trackWidth;
@synthesize highlightColor = _highlightColor;
@synthesize highlightPadding = _highlightPadding;
@synthesize handleColor = _handleColor;
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
    self.trackWidth = 10.0;
    self.highlightColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    self.highlightPadding = 0.0;
    self.handleColor = [UIColor redColor];
    self.handleSize = 22.0;
    self.handlePadding = 11.0;
    self.dividerWidth = 1.0;
    self.dividerPadding = 0.0;
    self.showFlag = YES;
    self.flagColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.flagSize = CGSizeMake(160.0, 30.0);
    self.flagCornerRadius = 5.0;
    self.flagPadding = 14.0;
    self.font = [UIFont systemFontOfSize:14.0];
    self.textColor = [UIColor darkGrayColor];
    self.minValue = 0.0;
    self.maxValue = 100.0;
    self.animationDuration = 0.2;
    self.format = @"%.2f";
    self.value = 50.0;
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
    
    _slide.backgroundColor = self.highlightColor.CGColor;
    
    [_track.layer addSublayer:_slide];
    
    
    
    _dividers = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.trackWidth - (2 * self.dividerPadding))];
    
    _dividers.center = _trackCenter;
    
    [self addSubview:_dividers];
    

    
    _handle = [[MJPSliderHandle alloc] initWithFrame:CGRectMake(0.0, 0.0, self.handleSize, self.handleSize)];
    
    _handle.backgroundColor = self.handleColor;
    
    _handle.center = _trackCenter;
    
    _handle.layer.cornerRadius = self.handleSize / 2;
    
    [self addSubview:_handle];
    
    
    _triangle = [CAShapeLayer layer];
    
    _triangle.path = [self pathForFlag].CGPath;
    
    _triangle.fillColor = [self.flagColor CGColor];
    
    [_handle.layer addSublayer:_triangle];
    
    
    _flag = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.flagSize.width, self.flagSize.height)];
    
    _flag.center = CGPointMake(_trackCenter.x, _trackCenter.y - (self.handleSize / 2) - self.flagPadding - (_flag.frame.size.height / 2));
    
    _flag.layer.cornerRadius = self.flagCornerRadius;
    
    _flag.backgroundColor = self.flagColor;
    
    [self addSubview:_flag];
    
    
    _flagTitle = [[UILabel alloc] initWithFrame:_flag.bounds];
    
    _flagTitle.font = self.font;
    
    _flagTitle.textColor = self.textColor;
    
    _flagTitle.textAlignment = NSTextAlignmentCenter;
    
    _flagTitle.text = [NSString stringWithFormat:self.format, self.value];
    
    [_flag addSubview:_flagTitle];
    
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
    
    [_handle addGestureRecognizer:_pan];
    
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:UIDeviceOrientationDidChangeNotification];
}

#pragma mark - Public

- (void)setDividerPoints:(NSArray *)options
{
    self.style = kSliderStyleDivided;
    
    self.format = @"%@ - %.2f";
    
    _titles = [NSMutableArray new];
    _values = [NSMutableArray new];
    _points = [NSMutableArray new];
    
    CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding) - self.dividerWidth;
    
    CGFloat gap = total / (options.count - 1);
    
    CGFloat theX = (self.handleSize / 2) + self.handlePadding;
    
    CGFloat height = _dividers.frame.size.height;
    
    for(int i = 0; i < options.count; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(theX, 0.0, self.dividerWidth, height)];
        
        view.backgroundColor = self.handleColor;
        
        view.layer.cornerRadius = self.dividerWidth / 2;
        
        [_dividers addSubview:view];
        
        NSDictionary *option = options[i];
        
        [_titles addObject:option[@"title"]];
        
        [_values addObject:option[@"value"]];
        
        [_points addObject:[NSNumber numberWithFloat:view.center.x]];
        
        theX += gap;
    }
    
    NSInteger selected = (_points.count + 1) / 2;
    
    [self slideToValue:[NSNumber numberWithInteger:selected] animated:NO];
}

- (void)updateDividers
{
    _points = [NSMutableArray new];
    
    CGFloat total = self.frame.size.width - self.handleSize - (2 * self.handlePadding) - self.dividerWidth;
    
    CGFloat gap = total / (_titles.count - 1);
    
    CGFloat theX = (self.handleSize / 2) + self.handlePadding;
    
    CGFloat height = _dividers.bounds.size.height;
    
    for(UIView * subview in _dividers.subviews) {
        
        subview.frame = CGRectMake(theX, 0.0, self.dividerWidth, height);
        
        subview.backgroundColor = self.handleColor;
        
        subview.layer.cornerRadius = self.dividerWidth / 2;
        
        [_points addObject:[NSNumber numberWithFloat:subview.center.x]];
        
        theX += gap;
    }
    
    [self slideToValue:[NSNumber numberWithInteger:_currentIndex] animated:NO];
}

- (void)slideToValue:(id)value animated:(BOOL)animated
{
    CGPoint newHandle;
    
    if(self.style == kSliderStyleSliding) {
        
        CGFloat floatValue = [value floatValue];
        
        floatValue = (floatValue < self.minValue) ? self.minValue : floatValue;
        
        floatValue = (floatValue > self.maxValue) ? self.maxValue : floatValue;
        
        newHandle =  CGPointMake([self positionFromValue:floatValue], _track.center.y);
        
        _flagTitle.text = [NSString stringWithFormat:self.format, floatValue];
        
    } else {
        
        NSInteger index = [value integerValue];
        
        newHandle = CGPointMake([_points[index] floatValue], _track.center.y);
        
        NSString *title = _titles[index];
        
        CGFloat value = [_values[index] floatValue];
        
        _flagTitle.text = [NSString stringWithFormat:self.format, title, value];
    }
    
    
    CGFloat constrainLeft = self.flagSize.width / 2;
    
    CGFloat constrainRight = self.frame.size.width - (self.flagSize.width / 2);
    
    CGFloat flagPosition = newHandle.x;
    
    flagPosition = MAX(constrainLeft, flagPosition);
    
    flagPosition = MIN(flagPosition, constrainRight);
    
    CGPoint newFlag = CGPointMake(flagPosition, _flag.center.y);
    
    
    CGRect slideFrame = _slide.frame;
    
    slideFrame.size.width = newHandle.x;
    
    if(animated) {
        
        [UIView animateWithDuration:self.animationDuration
                         animations:^{
                             
                             _handle.center = newHandle;
                             _flag.center = newFlag;
                             _slide.frame = slideFrame;
                             
                         }];
        
    } else {
        
        _handle.center = newHandle;
        
        _flag.center = newFlag;
        
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
    CGFloat point = 0.0;
    
    if(self.trackWidth > self.handleSize) {
        
        point = (self.handleSize - self.trackWidth) / 2;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0.0, 0.0 - self.flagPadding)];
    
    [path addLineToPoint:CGPointMake(self.handleSize, 0.0 - self.flagPadding)];
    
    [path addLineToPoint:CGPointMake(self.handleSize / 2, point)];
    
    return path;
}

- (void)dragHandle:(UIPanGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        if([self.delegate respondsToSelector:@selector(sliderWillMove:)]) {
            
            [self.delegate sliderWillMove:self];
        }
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translated = [gesture locationInView:self];
        
        translated.y = _trackCenter.y;
        
        translated.x = MAX(translated.x, _valueMin);
        
        translated.x = MIN(_valueMax, translated.x);
        
        if(self.style == kSliderStyleSliding) {
            
            _handle.center = translated;
            
            self.value = [self valueFromPosition:translated.x];
            
            if(self.round > 0)
                self.value = round(self.value / self.round) * self.round;
            
            _flagTitle.text = [NSString stringWithFormat:self.format, self.value];
            
            [self setSliderWidthToMeetPoint:translated animated:NO];
            
            if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                
                [self.delegate sliderDidMove:self];
            }
            
        } else {
            
            NSInteger before = self.currentIndex;
            
            CGPoint velocity = [gesture velocityInView:self];
            
            CGPoint nearest = [self nearestPointToValue:translated.x];
            
            if(velocity.x > 500.0 || velocity.x < -500.0) {
                
                _handle.center = nearest;
                
                [self setSliderWidthToMeetPoint:nearest animated:NO];
                
                if(before != self.currentIndex) {
                    
                    self.value = [_values[self.currentIndex] floatValue];
                    
                    NSString *title = _titles[self.currentIndex];
                    
                    _flagTitle.text = [NSString stringWithFormat:self.format, title, self.value];
                    
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        
                        [self.delegate sliderDidMove:self];
                    }
                }
                
            } else {
            
                if(before != self.currentIndex) {
                    
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         
                                         _handle.center = nearest;
                                         
                                     }];
                    
                    [self setSliderWidthToMeetPoint:nearest animated:YES];
                    
                    self.value = [_values[self.currentIndex] floatValue];
                    
                    NSString *title = _titles[self.currentIndex];
                    
                    _flagTitle.text = [NSString stringWithFormat:self.format, title, self.value];
                    
                    if([self.delegate respondsToSelector:@selector(sliderDidMove:)]) {
                        
                        [self.delegate sliderDidMove:self];
                    }
                }
            }
        }
        
        translated.y = _flag.center.y;
        
        translated.x = MAX(translated.x, self.flagSize.width / 2);
        
        translated.x = MIN(self.frame.size.width - (self.flagSize.width / 2), translated.x);
        
        _flag.center = translated;
    }
    
    if(gesture.state == UIGestureRecognizerStateEnded) {
        
        if(self.style == kSliderStyleSliding) {
            
            self.value = [self valueFromPosition:_handle.center.x];
            
            if(self.round > 0)
                self.value = round(self.value / self.round) * self.round;
            
        } else {
            
            self.value = [_values[self.currentIndex] floatValue];
        }
        
        if([self.delegate respondsToSelector:@selector(sliderDidFinish:)]) {
            
            [self.delegate sliderDidFinish:self];
        }
    }
}

- (void)setSliderWidthToMeetPoint:(CGPoint)point animated:(BOOL)animated
{
    CGRect slideFrame = _slide.frame;
    
    slideFrame.size.width = point.x;
    
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

- (void)orientationChanged:(id)sender
{
    [self calculateMinMax];
    
    if(_titles.count > 0) {
        
        [self updateDividers];
        
    } else {
        
        [self slideToValue:[NSNumber numberWithFloat:self.value] animated:YES];
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


#pragma mark - Nearest

- (CGPoint)nearestPointToValue:(CGFloat)value
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
        
        if (leftDifference < rightDifference)
            --index;
    }
    
    index = MIN(_points.count - 1, index);
    
    index = MAX(index, 0);
    
    self.currentIndex = index;
    
    CGFloat pointX = [_points[index] floatValue];
    
    CGFloat finalPoint;
    
    CGFloat threshold = 10.0;
    
    if(value < pointX + threshold || value > pointX - threshold) {
        
        finalPoint = pointX;
        
    } else {
        
        finalPoint = value;
    }
    
    return CGPointMake(pointX, _trackCenter.y);
}

#pragma mark - Color

- (UIColor *)shadeOfColor:(UIColor *)color shade:(CGFloat)shade
{
    CGFloat h, s, b, a;
    
    if([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b * shade, 1.0) alpha:a];
    }
    
    return color;
}


#pragma mark - Getters / Setters

- (void)setTrackColor:(UIColor *)trackColor
{
    _trackColor = trackColor;
    
    _track.backgroundColor = trackColor;
    
    _lightTrackColor = [trackColor colorWithAlphaComponent:0.6];
}

- (void)setTrackWidth:(CGFloat)trackWidth
{
    _trackWidth = trackWidth;
    
    _trackConstraintWidth.constant = trackWidth;
    
    [_track setNeedsUpdateConstraints];
    
    [_track layoutIfNeeded];
    
    _track.layer.cornerRadius = trackWidth / 2;
    
    _dividers.bounds = CGRectMake(0.0, 0.0, self.frame.size.width, trackWidth + (2 * self.dividerPadding));
    
    _triangle.path = [self pathForFlag].CGPath;
    
    if(_titles.count > 0) {
        
        [self updateDividers];
    }
    
    _slide.frame = CGRectMake(0.0, 0.0, _slide.bounds.size.width, trackWidth);
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor;
    
    _slide.backgroundColor = highlightColor.CGColor;
}

- (void)setHighlightPadding:(CGFloat)highlightPadding
{
    _highlightPadding = highlightPadding;
    
    _track.layer.borderWidth = highlightPadding;
    
    _track.layer.borderColor = self.trackColor.CGColor;
    
    _track.backgroundColor = _lightTrackColor;
}

- (void)setHandleColor:(UIColor *)handleColor
{
    _handleColor = handleColor;
    
    _handle.backgroundColor = handleColor;
}

- (void)setHandleSize:(CGFloat)handleSize
{
    CGFloat original = _handleSize;
    
    _handleSize = handleSize;
    
    _handle.bounds = CGRectMake(0.0, 0.0, handleSize, handleSize);
    
    _handle.layer.cornerRadius = handleSize / 2;
    
    
    CGPoint flagCenter = _flag.center;
    
    flagCenter.y -= (handleSize / 2) - (original / 2);
    
    _flag.center = flagCenter;
    
    
    _triangle.path = [self pathForFlag].CGPath;
    
    
    [self calculateMinMax];
}

- (void)setHandlePadding:(CGFloat)handlePadding
{
    _handlePadding = handlePadding;
    
    [self calculateMinMax];
    
    if(self.style == kSliderStyleDivided && _titles.count > 0) {
        
        [self updateDividers];
    }
}

- (void)setDividerWidth:(CGFloat)dividerWidth
{
    _dividerWidth = dividerWidth;
    
    

    if(self.style == kSliderStyleDivided && _titles.count > 0) {
        
        [self updateDividers];
    }
}

- (void)setDividerPadding:(CGFloat)dividerPadding
{
    _dividerPadding = dividerPadding;
    
    _dividers.bounds = CGRectMake(0.0, 0.0, self.frame.size.width, self.trackWidth + (2 * dividerPadding));
    
    _dividers.center = _trackCenter;
    
    if(self.style == kSliderStyleDivided && _titles.count > 0) {
        
        [self updateDividers];
    }
}

- (void)setShowFlag:(BOOL)showFlag
{
    _showFlag = showFlag;
    
    _flag.hidden = !showFlag;
    
    _triangle.hidden = !showFlag;
}

- (void)setFlagColor:(UIColor *)flagColor
{
    _flagColor = flagColor;
    
    _flag.backgroundColor = flagColor;
    
    _triangle.fillColor = flagColor.CGColor;
}

- (void)setFlagSize:(CGSize)flagSize
{
    CGFloat difference = (_flagSize.height - flagSize.height) / 2;
    
    _flagSize = flagSize;
    
    _flag.bounds = CGRectMake(0.0, 0.0, flagSize.width, flagSize.height);
    
    _flag.center = CGPointMake(_flag.center.x, _flag.center.y + difference);
    
    _flagTitle.frame = _flag.bounds;
}

- (void)setFlagCornerRadius:(CGFloat)flagCornerRadius
{
    _flagCornerRadius = flagCornerRadius;
    
    _flag.layer.cornerRadius = flagCornerRadius;
}

- (void)setFlagPadding:(CGFloat)flagPadding
{
    CGFloat difference = self.flagPadding - flagPadding;
    
    _flagPadding = flagPadding;
    
    _flag.center = CGPointMake(_flag.center.x, _flag.center.y + difference);
    
    _triangle.path = [self pathForFlag].CGPath;
}

- (void)setFont:(UIFont *)font
{
    _font = font;
    
    _flagTitle.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    _flagTitle.textColor = _textColor;
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    
    //[self slideToValue:[NSNumber numberWithFloat:value] animated:NO];
}

- (void)setEnabled:(BOOL)enabled
{
    [self setEnabled:enabled animated:NO];
}

- (void)setEnabled:(BOOL)enabled animated:(BOOL)animated
{
    [super setEnabled:enabled];
    
    self.userInteractionEnabled = enabled;
    
    CGFloat alpha;
    
    if(enabled)
        alpha = 1.0;
    
    else
        alpha = 0.5;
    
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
    }
    
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.hitFrame, point)) {
        
        return YES;
        
    } else {
        
        return NO;
    }
}

@end