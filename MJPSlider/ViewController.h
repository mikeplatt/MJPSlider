//
//  ViewController.h
//  MJPSlider
//
//  Created by Mike Platt on 28/07/2014.
//  Copyright (c) 2014 Capco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJPSlider.h"

@interface ViewController : UIViewController <MJPSliderDelegate>

@property (nonatomic, weak) IBOutlet MJPSlider *example1;
@property (nonatomic, weak) IBOutlet MJPSlider *example2;
@property (nonatomic, weak) IBOutlet MJPSlider *example3;

@end
