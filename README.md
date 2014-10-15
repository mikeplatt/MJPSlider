[![License: MIT](https://img.shields.io/badge/license-MIT-red.svg?style=flat)](https://github.com/fastred/MJPSlider/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/MJPSlider.svg?style=flat)](https://github.com/fastred/MJPSlider)

## Synopsis

`MJPSlider` is a `UISlider` replacement with options to create a second handle, handle flags and divisions.


## Installation
 
 `MJPSlider` is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:
 
 `pod 'MJPSlider'`
 
 If you don't use CocoaPods, just include these files in your project:

`MJPSlider.h`
`MJPSlider.m`


## Features
Standard
• `minValue`
• `maxValue`
• `setValue:(CGFloat)value animated:(BOOL)animated;`
Range Slider 
• `isRangeSlider` (adds second handle)
• `minRange` (minimum allowed value between the two handles)
• `setLowerValue:(CGFloat)lowerValue upperValue:(CGfloat)upperValue animated:(BOOL)animated;`
Flags
• `showFlag`           
• `textColor`
• `font`
• `flagColor`
• `flagSize`
• `flagCornerRadius`
• `flagPadding` (distance between handle and flag)

## Code Example

```objective-c
MJPSlider *slider = [[MJPSlider alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 40.0)];
slider.minValue = 1.0;
slider.maxValue = 20.0;
slider.showFlag = YES;
slider.tintColor = [UIColor redColor];
```

