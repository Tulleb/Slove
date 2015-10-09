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
#import "SLVContact.h"
#import "SLVInteractionPopupViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, SLVInteractionPopupDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLVNavigationController *currentNavigationController;
@property (strong, nonatomic) NSArray *countryCodeDatas;
@property (nonatomic, strong) SLVCountryCodeData *userCountryCodeData;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) SLVContact *sloverToSlove;
@property (nonatomic, strong) NSMutableDictionary *parseConfig;
@property (nonatomic) BOOL userIsConnected;
@property (strong, nonatomic) NSMutableArray *queuedPopups;
@property (nonatomic) BOOL alreadyCheckedCompatibleVersion;
@property (nonatomic, strong) SLVInteractionPopupViewController *compatibleVersionPopup;
@property (nonatomic) BOOL applicationJustStarted;

- (void)userConnected;
- (void)userDisconnected;

@end

