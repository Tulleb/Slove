//
//  SLVSettingsViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSettingsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SLVConstructionPopupViewController.h"

@interface SLVSettingsViewController ()

@end

@implementation SLVSettingsViewController

- (void)viewDidLoad {
	self.appName = @"settings";
	
    [super viewDidLoad];
	
	[self loadBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	SLVConstructionPopupViewController *constructionPopup = [[SLVConstructionPopupViewController alloc] init];
	
	[self.navigationController presentViewController:constructionPopup animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateProfileAction:(id)sender {
}

- (IBAction)disconnectAction:(id)sender {
	if ([FBSDKAccessToken currentAccessToken]) {
		[FBSDKAccessToken setCurrentAccessToken:nil];
	}
	
	[PFUser logOutInBackgroundWithBlock:^(NSError * error) {
		if (!error) {
			[ApplicationDelegate userDisconnected];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

- (void)goBack:(id)sender {
	[super goToHome];
}

@end
