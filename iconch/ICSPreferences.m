//
//  ICSPreferences.m
//  iConch
//
//  Created by Joseph Schwartz on 6/30/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//

#import "ICSPreferences.h"

NSString const*  BAD_SOUND_THRESHOLD_KEY    = @"BadSound";
NSString const*  GOOD_SOUND_THRESHOLD_KEY   = @"GoodSound";
NSString const*  SHOW_INSTRUCTIONS_KEY      = @"ShowInstructions";

float            BAD_SOUND_THRESHOLD_DEFAULT     = -35.0;
float            GOOD_SOUND_THRESHOLD_DEFAULT    = -5.0;

@implementation ICSPreferences

+(void) setDefaults
{
    NSDictionary *appDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithFloat: BAD_SOUND_THRESHOLD_DEFAULT],BAD_SOUND_THRESHOLD_KEY,
                             [NSNumber numberWithFloat:GOOD_SOUND_THRESHOLD_DEFAULT], GOOD_SOUND_THRESHOLD_KEY, nil];
    
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDict];
}

-(float) badSoundThreshold
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:(NSString*)BAD_SOUND_THRESHOLD_KEY];
}

-(void) setBadSoundThreshold:(float)badSoundThreshold
{
    [[NSUserDefaults standardUserDefaults] setFloat:badSoundThreshold forKey:(NSString*)BAD_SOUND_THRESHOLD_KEY];
}

-(float) goodSoundThreshold
{
    return [[NSUserDefaults standardUserDefaults] floatForKey:(NSString*)GOOD_SOUND_THRESHOLD_KEY];
}

-(void) setGoodSoundThreshold:(float)goodSoundThreshold
{
    [[NSUserDefaults standardUserDefaults] setFloat:goodSoundThreshold forKey:(NSString*)GOOD_SOUND_THRESHOLD_KEY];
}

-(BOOL) showInstructions
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:(NSString*)SHOW_INSTRUCTIONS_KEY];
}

-(void) setShowInstructions:(BOOL)showInstructions
{
    [[NSUserDefaults standardUserDefaults] setBool:showInstructions forKey:(NSString*)SHOW_INSTRUCTIONS_KEY];
}

@end
