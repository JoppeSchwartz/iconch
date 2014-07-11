//
//  ICSMainViewController.h
//  iConch
//
//  Created by Joseph Schwartz on 6/29/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "ICSFlipsideViewController.h"

@interface ICSMainViewController : UIViewController <ICSFlipsideViewControllerDelegate>
@property AVAudioSession *session;
@property AVAudioPlayer *player;
@property AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet UIButton *doItButton;
@property (weak, nonatomic) IBOutlet UILabel *avgPwrLabel;
@property (weak, nonatomic) IBOutlet UIButton *altViewButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

- (IBAction)doItClicked:(id)sender;
- (IBAction)volumeSliderChanged:(id)sender;
@end
