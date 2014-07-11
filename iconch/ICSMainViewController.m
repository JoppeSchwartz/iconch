//
//  ICSMainViewController.m
//  iConch
//
//  Created by Joseph Schwartz on 6/29/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//

#import "ICSMainViewController.h"
#import "ICSPreferences.h"
#include <stdlib.h>

NSString *const         LABEL_BLOW      = @"tap and blow.";
NSString *const         LABEL_STOP      = @"omg make it stop.";
NSString *const         LABEL_AVG_PWR   = @"average blow power";
const NSTimeInterval    TIMER_DELAY     = 0.25;
const float             SAMPLE_RATE     = 44100.0;
const int               NUM_CHANNELS    = 1;
const float             DEFAULT_VOLUME  = 0.5;

typedef enum __PlayerState {STOPPED, BAD, GOOD} PlayerState;


@interface ICSMainViewController ()
{
    NSTimer         *_timer;
    BOOL            _conching;
    PlayerState     _playerState;
    float           _badThreshold;
    float           _goodThreshold;
}
@end

@implementation ICSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //  Set state variables.
    _conching = NO;
    _playerState = STOPPED;
    
    //  Set up UI.
    self.volumeSlider.value = DEFAULT_VOLUME;
    [self.doItButton setTitle:LABEL_BLOW forState:UIControlStateNormal];
    //  This is a workaround for an iOS 7 bug.  Apple knows, hasn't yet fixed.
    [self.volumeSlider setThumbImage:[UIImage imageNamed:@"speaker.png"] forState:UIControlStateNormal];
    [self.volumeSlider setThumbTintColor:[UIColor blackColor]];
    
    //  Set up the audio session.
    self.session = [AVAudioSession sharedInstance];

    NSError *err = nil;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if (err) {
        NSLog(@"Error setting audio session category: %@", err.description);
        return;
    }
    [self.session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&err];
    if (err) {
        NSLog(@"Error setting audio seession port to speaker: %@", err.description);
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioInterrupted:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:self.session];
    
    BOOL res = [self.session setActive:YES error:&err];
    if (! res) {
        NSLog(@"Error activating audio session: %@", err.description);
        return;
    }
    //  Set up the recorder.
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithFloat:SAMPLE_RATE], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt:NUM_CHANNELS], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey,
                              nil];
    
    NSString *recordFilePath = [NSTemporaryDirectory() stringByAppendingString:@"tmp.caf"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:recordFilePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&err];
    if (err) {
        NSLog(@"Error instantiating the audio recorder: %@", err.description);
        return;
    }
    [self.recorder prepareToRecord];
    self.recorder.meteringEnabled = YES;
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if (_conching) [self stopConching];
}

-(void) viewDidAppear:(BOOL)animated
{
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    if (_conching) [self stopConching];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(ICSFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [((ICSFlipsideViewController*)[segue destinationViewController]) setDelegate:self];
    }
}

#pragma mark - UI

- (IBAction)doItClicked:(id)sender {
    if (!_conching) {
        [self startConching];
    }
    else {
        [self stopConching];
    }
}

- (IBAction)volumeSliderChanged:(id)sender
{
    if (self.player) {
        self.player.volume = self.volumeSlider.value;
        NSLog(@"New volume: %f", self.volumeSlider.value);
    }
}

#pragma mark Audio


-(void) startConching
{
 
    //  Read the current preferences for the dB thresholds.
    //  This is done once per conching session so as not to hit the prefernces database
    //  in a timer loop.
    ICSPreferences *prefs = [[ICSPreferences alloc] init];
    _badThreshold = prefs.badSoundThreshold;
    _goodThreshold = prefs.goodSoundThreshold;


    
    //  Start recording.
    [self.recorder record];
    //  Register a time for the main run loop.
    _timer = [NSTimer timerWithTimeInterval:TIMER_DELAY
                                     target:self
                                   selector:@selector(sampleRecording:)
                                   userInfo:nil
                                    repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    //  Set the UI.
    [self.doItButton setTitle:LABEL_STOP forState:UIControlStateNormal];
    self.altViewButton.enabled = NO;
    _conching = YES;
}

-(void) stopConching
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [self.recorder stop];
    [self.recorder deleteRecording];
    [self.doItButton setTitle:LABEL_BLOW forState:UIControlStateNormal];
    [self setPlayerState:STOPPED];
    self.altViewButton.enabled = YES;
    _conching = NO;
}



-(void) sampleRecording:(NSTimer*)timer
{
    if (self.recorder.recording) {
        [self.recorder updateMeters];
//        float peakPower = [self.recorder peakPowerForChannel:0];
        float avgpower = [self.recorder averagePowerForChannel:0];

//        NSLog(@"Peak pwr: %3.3f\tAvg pwr: %3.3f", peakPower, avgpower);
//        self.peakPwrLabel.text = [NSString stringWithFormat:@"Peak Pwr:%3.3f", peakPower];
        self.avgPwrLabel.text = [NSString stringWithFormat:@"%@: %3.2fdB", LABEL_AVG_PWR, avgpower];
        
        if (avgpower < _badThreshold) {
            [self setPlayerState:STOPPED];
        }
        else if (avgpower < _goodThreshold) {
            if (_playerState != BAD)
                [self setPlayerState:BAD];
        }
        else {
            if (_playerState != GOOD)
                [self setPlayerState:GOOD];
        }
    }
}

-(NSError*) playMP3:(NSString*)fileName
{
    [self stopPlaying];
    NSError *err = nil;
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL fileTypeHint:AVFileTypeMPEGLayer3 error:&err];
    self.player = newPlayer;
    self.player.volume = self.volumeSlider.value;
    NSLog(@"set volume to %f", self.volumeSlider.value);
    [self.player play];
    return err;
}

-(NSError*) setPlayerState:(PlayerState)newState
{
    NSError *err = nil;
    int version = (rand() >= (RAND_MAX / 2) ? 2 : 1);
    
    switch (newState) {
        case STOPPED:
            [self stopPlaying];
            break;
        case BAD:
            [self playMP3: (version == 1 ? @"BadConch1" : @"BadConch2")];
            break;
        case GOOD:
            [self playMP3: (version == 1 ? @"GoodConch1" : @"GoodConch2")];
            break;
    }
    _playerState = newState;
    NSLog(@"New state:%d", newState);
    return err;
}

-(void) stopPlaying
{
    if(self.player) {
        if (self.player.playing)
            [self.player stop];
        self.player = nil;
    }
    _playerState = STOPPED;
}

-(void) audioInterrupted:(NSNotification *)notification
{
    NSNumber *type = [notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    int itype = [type intValue];
    NSLog(@"Audio interruption type %d", itype);
    //  Just stop playing and do not restart; if the user wants to restart he will.
    if (itype == AVAudioSessionInterruptionTypeBegan) {
        [self setPlayerState:STOPPED];
    }
}

@end
