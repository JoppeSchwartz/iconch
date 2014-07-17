//
//  ICSFlipsideViewController.m
//  iConch
//
//  Created by Joseph Schwartz on 6/29/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//

#import "ICSFlipsideViewController.h"
#import "ICSPreferences.h"


@interface ICSFlipsideViewController ()
{
    ICSPreferences *_prefs;
}
@end

@implementation ICSFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //  Workaround for slider UI bug.
    [self.badSoundSlider setThumbImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
    [self.badSoundSlider setThumbTintColor:[UIColor blackColor]];
    [self.goodSoundSlider setThumbImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
    [self.goodSoundSlider setThumbTintColor:[UIColor blackColor]];
    
    
    //  Set up UI to reflect currently stored preferences.
    _prefs = [[ICSPreferences alloc] init];
    self.badLabel.text = [NSString stringWithFormat:@"%3.2f", _prefs.badSoundThreshold];
    self.goodLabel.text = [NSString stringWithFormat:@"%3.2f", _prefs.goodSoundThreshold];
    self.badSoundSlider.value = _prefs.badSoundThreshold;
    self.goodSoundSlider.value = _prefs.goodSoundThreshold;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    _prefs.badSoundThreshold = self.badSoundSlider.value;
    _prefs.goodSoundThreshold = self.goodSoundSlider.value;
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)badThresholdChanged:(id)sender
{
    if (self.badSoundSlider.value >= self.goodSoundSlider.value) {
        self.badSoundSlider.value = self.goodSoundSlider.value - 1.0;
    }
    self.badLabel.text = [NSString stringWithFormat:@"%3.2f dB", self.badSoundSlider.value];
    
}

- (IBAction)goodThresholdChanged:(id)sender
{
    if (self.goodSoundSlider.value <= self.badSoundSlider.value) {
        self.goodSoundSlider.value = self.badSoundSlider.value + 1.0;
    }
    self.goodLabel.text = [NSString stringWithFormat:@"%3.2f dB", self.goodSoundSlider.value];
}


@end
