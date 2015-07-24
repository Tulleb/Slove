//
//  AppDelegate.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLVNavigationViewController.h"
#import <Parse/PFUser.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLVNavigationViewController *currentNavigationController;
@property (strong, nonatomic) PFUser *currentUser;

- (void)userIsConnected;

@end

