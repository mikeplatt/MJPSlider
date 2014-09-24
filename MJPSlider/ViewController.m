//
//  ViewController.m
//  MJPSlider
//
//  Created by Mike Platt on 28/07/2014.
//  Copyright (c) 2014 Capco. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.example1.tag = 0;
    self.example1.showFlag = NO;
    [self.example1 setValue:50.0 animated:NO];
    
    self.example2.tag = 1;
    self.example2.isRangeSlider = YES;
    self.example2.tintColor = [UIColor greenColor];
    self.example2.minValue = 10.0;
    self.example2.maxValue = 30.0;
    self.example2.minRange = 5.0;
    self.example2.flagSize = CGSizeMake(70.0, 30.0);
    self.example2.flagCornerRadius = 0.0;
    self.example2.round = 0.2;
    [self.example2 setLowerValue:10.0 andUpperValue:30.0 animated:NO];
    
    
    self.example3.tag = 2;
    self.example3.dividerPadding = 5.0;
    self.example3.tintColor = [UIColor purpleColor];
    [self.example3 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 } ]];
    
    
    self.example4.tag = 3;
    self.example4.isRangeSlider = YES;
    self.example4.flagSize = CGSizeMake(120.0, 30.0);
    self.example4.tintColor = [UIColor redColor];
    [self.example4 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 }, @{ @"title" : @"Extreme", @"value" : @52.00 }, @{ @"title" : @"Super", @"value" : @70.00 } ]];
    self.example4.format = @"%@";
    self.example4.minRange = 1;
    [self.example4 setLowerValue:0 andUpperValue:4 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)sliderWillMove:(MJPSlider *)slider
{
    if(slider.isRangeSlider) {
        NSLog(@"EXAMPLE %ld - WILL MOVE - LOWER VALUE: %.2f  UPPER VALUE: %.2f", (long)slider.tag, slider.lowerValue, slider.upperValue);
    } else {
        NSLog(@"EXAMPLE %ld - WILL MOVE: %.2f", (long)slider.tag, slider.value);
    }
}

- (void)sliderDidMove:(MJPSlider *)slider
{
    if(slider.isRangeSlider) {
        NSLog(@"EXAMPLE %ld - DID MOVE - LOWER VALUE: %.2f  UPPER VALUE: %.2f", (long)slider.tag, slider.lowerValue, slider.upperValue);
    } else {
        NSLog(@"EXAMPLE %ld - DID MOVE: %.2f", (long)slider.tag, slider.value);
    }
}

- (void)sliderDidFinish:(MJPSlider *)slider
{
    if(slider.isRangeSlider) {
        NSLog(@"EXAMPLE %ld - DID FINISH - LOWER VALUE: %.2f  UPPER VALUE: %.2f", (long)slider.tag, slider.lowerValue, slider.upperValue);
    } else {
        NSLog(@"EXAMPLE %ld - DID FINISH: %.2f", (long)slider.tag, slider.value);
    }
}

@end
