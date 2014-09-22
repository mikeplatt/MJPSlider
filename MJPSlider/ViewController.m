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
    self.example2.handleColor = [UIColor greenColor];
    self.example2.highlightColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
    self.example2.minValue = 10.0;
    self.example2.maxValue = 30.0;
    self.example2.minRange = 5.0;
    self.example2.flagSize = CGSizeMake(50.0, 30.0);
    self.example2.round = 0.2;
    [self.example2 setLowerValue:10.0 andUpperValue:30.0 animated:NO];
    
    
    self.example3.tag = 2;
    self.example3.trackWidth = 2.0;
    self.example3.dividerPadding = 5.0;
    self.example3.handleColor = [UIColor purpleColor];
    self.example3.highlightColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
    [self.example3 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 } ]];
    
    
    self.example4.tag = 3;
    self.example4.trackWidth = 28.0;
    self.example4.dividerPadding = -9.0;
    self.example4.dividerWidth = 10.0;
    self.example4.highlightPadding = 6.0;
    self.example4.handlePadding = 0.0;
    self.example4.handleColor = [UIColor blueColor];
    self.example4.highlightColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    [self.example4 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 } ]];
    self.example4.format = @"%@";
    [self.example4 setValue:1.00 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)sliderWillMove:(MJPSlider *)slider
{
    NSLog(@"EXAMPLE %ld - WILL MOVE: %.2f", (long)slider.tag, slider.value);
}

- (void)sliderDidMove:(MJPSlider *)slider
{
    NSLog(@"EXAMPLE %ld - DID MOVE: %.2f", (long)slider.tag, slider.value);
}

- (void)sliderDidFinish:(MJPSlider *)slider
{
    NSLog(@"EXAMPLE %ld - DID FINISH: %.2f", (long)slider.tag, slider.value);
}

@end
