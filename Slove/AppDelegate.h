//
//  AppDelegate.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLVNavigationController.h"
#import <Parse/PFUser.h>
#import "SLVCountryCodeData.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLVNavigationController *currentNavigationController;
@property (nonatomic) BOOL userIsConnected;
@property (strong, nonatomic) NSArray *countryCodeDatas;
@property (nonatomic, strong) SLVCountryCodeData *userCountryCodeData;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (void)userConnected;
- (void)userDisconnected;

@end

