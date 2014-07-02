//
//  ViewController.m
//  MJPSlider
//
//  Created by Mike Platt on 02/07/2014.
//  Copyright (c) 2014 rabfap. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MJPSlider *slider = [[MJPSlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 40.0)];
    
    slider.delegate = self;
    
    slider.center = self.view.center;
    
    [self.view addSubview:slider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)sliderChangedToValue:(CGFloat)value
{
    NSLog(@"VALUE: %.2f", value);
}

@end
