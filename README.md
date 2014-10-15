[![License: MIT](https://img.shields.io/badge/license-MIT-red.svg?style=flat)](https://github.com/fastred/MJPSlider/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/MJPSlider.svg?style=flat)](https://github.com/fastred/MJPSlider)

## Synopsis

`MJPSlider` is a `UISlider` replacement with options to create a second handle, handle flags and divisions.

![screenshot] (https://github.com/mikeplatt/MJPSlider/blob/master/screenshot.png)


## Installation
 
 `MJPSlider` is available through [CocoaPods](http://cocoapods.org/?q=MJPSlider). To install it, simply add the following line to your Podfile:
 
 `pod 'MJPSlider'`
 
 If you don't use CocoaPods, just include these files in your project:

`MJPSlider.h`
`MJPSlider.m`


## Standard Features
• `minValue`<br>
• `maxValue`<br>
• `tintColor`<br>
• `setValue:(CGFloat)value animated:(BOOL)animated`<br>
• `setEnabled:(BOOL)enabled animated:(BOOL)animated`

## Range Slider Features
• `isRangeSlider` (adds second handle)<br>
• `minRange` (minimum allowed value between the two handles)<br>
• `setLowerValue:(CGFloat)lowerValue andUpperValue:(CGfloat)upperValue animated:(BOOL)animated`

## Division Features
• `format` (NSString formatter value e.g. `@"%@ - %.2f"`)<br>
• `setDividerPoints:(NSArray *)dividers`<br>
• Format of divider points: `@{ @"title" : @"Title One", @"value" : @(10) }`<br>
Note:<br>
Setting dividers this must be done before setting the values.<br>
Setting values is then done by passing the `index` of the disired value in the divider point array  

## Flag Features
• `showFlag`<br>
• `textColor`<br>
• `font`<br>
• `flagColor`<br>
• `flagSize`<br>
• `flagCornerRadius`<br>
• `flagPadding` (distance between handle and flag)

## Delegate
For best results it is best to confirm to the `<MJPSliderDelegate>` methods:<br>
• `sliderWillMove:(MJPSlider *)slider`<br>
• `sliderDidMove:(MJPSlider *)slider`<br>
• `sliderDidFinish:(MJPSlider *)slider`

## Code Example
```objective-c
MJPSlider *slider = [[MJPSlider alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 40.0)];
slider.minValue = 1.0;
slider.maxValue = 20.0;
slider.showFlag = YES;
slider.tintColor = [UIColor redColor];
```


