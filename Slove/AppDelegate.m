//
//  AppDelegate.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "SLVConnectionViewController.h"
#import "SLVHomeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// [Optional] Power your app with Local Datastore. For more info, go to
	// https://parse.com/docs/ios_guide#localdatastore/iOS
	[Parse enableLocalDatastore];
 
	// Initialize Parse.
	[Parse setApplicationId:@"bNqrmF49ncJ0LYgfGIFZmReRkqKLFWtuCt2XJQFy"
				  clientKey:@"pJ5C1IkUz8hKdXd5pb3sZyDroMu6XfjhRgNiLO5q"];
 
	// [Optional] Track statistics around application opens.
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
	[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

	[FBSDKLoginButton class];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// TODO: get last User from NSUserDefault and check if connected
	
	self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:[[SLVConnectionViewController alloc] init]];
	self.window.rootViewController = self.currentNavigationController;
	[self.window addSubview:self.currentNavigationController.view];
	[self.window makeKeyAndVisible];
	
	return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [[FBSDKApplicationDelegate sharedInstance] application:application
														  openURL:url
												sourceApplication:sourceApplication
													   annotation:annotation];
}


#pragma mark - Custom methods

- (void)userConnected {
	SLVLog(@"User '%@' connected on Slove", [PFUser currentUser].username);
	self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:[[SLVHomeViewController alloc] init]];
	self.window.rootViewController = self.currentNavigationController;
	
	userIsConnected = YES;
}

- (void)userDisconnected {
	SLVLog(@"User disconnected from Slove");
	
	if (userIsConnected) {
		self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:[[SLVConnectionViewController alloc] init]];
		self.window.rootViewController = self.currentNavigationController;
	}
	
	userIsConnected = NO;
}

@end
