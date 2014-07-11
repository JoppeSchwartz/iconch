//
//  ICSPreferences.h
//  iConch
//
//  Created by Joseph Schwartz on 6/30/14.
//  Copyright (c) 2014 Joseph Schwartz. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString const*  BAD_SOUND_THRESHOLD_KEY;
extern NSString const*  GOOD_SOUND_THRESHOLD_KEY;
extern NSString const*  SHOW_INSTRUCTIONS_KEY;

extern float            BAD_SOUND_THRESHOLD_DEFAULT;
extern float            GOOD_SOUND_THRESHOLD_DEFAULT;

@interface ICSPreferences : NSObject

+(void) setDefaults;

@property (nonatomic) float     badSoundThreshold;
@property (nonatomic) float     goodSoundThreshold;
@property (nonatomic) BOOL      showInstructions;
@end
