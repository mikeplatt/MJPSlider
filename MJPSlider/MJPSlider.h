//
//  MJPSlider.h
//  MJPLineGraph
//
//  Created by Mike Platt on 01/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MJPSliderDelegate <NSObject>

@required
- (void)sliderChangedToValue:(CGFloat)value;

@end

@interface MJPSlider : UIControl

@property (nonatomic, assign) id<MJPSliderDelegate> delegate;

@end
