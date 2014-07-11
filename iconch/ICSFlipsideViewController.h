//
//  ICSFlipsideViewController.h
//  iConch
//
//  Created by Joseph Schwartz on 6/29/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ICSFlipsideViewController;

@protocol ICSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(ICSFlipsideViewController *)controller;
@end

@interface ICSFlipsideViewController : UIViewController

@property (weak, nonatomic) id <ICSFlipsideViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UISlider *badSoundSlider;
@property (weak, nonatomic) IBOutlet UISlider *goodSoundSlider;

@property (weak, nonatomic) IBOutlet UILabel *badLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodLabel;
@property (weak, nonatomic) IBOutlet UITextView *instructions;

- (IBAction)badThresholdChanged:(id)sender;
- (IBAction)goodThresholdChanged:(id)sender;
- (IBAction)done:(id)sender;

@end
