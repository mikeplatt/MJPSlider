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
    
    self.example1.tag = 1;
    
    self.example1.minValue = 10.0;
    
    self.example1.maxValue = 30.0;
    
    self.example1.round = 1;
    
    self.example1.value = 20.0;
    
    
    self.example2.tag = 2;
    
    self.example2.trackWidth = 2.0;
    
    self.example2.dividerPadding = 5.0;
    
    self.example2.handleColor = [UIColor purpleColor];
    
    self.example2.highlightColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
    
    [self.example2 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 } ]];
    
    
    self.example3.tag = 3;
    
    self.example3.trackWidth = 28.0;
    
     self.example3.dividerPadding = -9.0;
    
    self.example3.dividerWidth = 10.0;
    
    self.example3.highlightPadding = 6.0;
    
    self.example3.handlePadding = 0.0;
    
    self.example3.handleColor = [UIColor blueColor];
    
    self.example3.highlightColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    
    [self.example3 setDividerPoints:@[ @{ @"title" : @"Basic", @"value" : @23.50 }, @{ @"title" : @"Standard", @"value" : @32.99 }, @{ @"title" : @"Delux", @"value" : @39.00 } ]];
    
    //self.example3.value = 2;
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
