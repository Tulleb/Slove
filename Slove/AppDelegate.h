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

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
	BOOL userIsConnected;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLVNavigationController *currentNavigationController;

- (void)userConnected;
- (void)userDisconnected;

@end

