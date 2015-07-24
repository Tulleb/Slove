//
//  ConnectionViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "ConnectionViewController.h"
#import "PhoneNumberViewController.h"
#import "HomeViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	
	FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
	if (accessToken) {
		[PFFacebookUtils logInInBackgroundWithAccessToken:accessToken
													block:^(PFUser *user, NSError *error) {
														if (!user) {
															SLVLog(@"%@Can't log in with Facebook", LOG_ERROR);
														} else {
															SLVLog(@"User '%@' logged in through Facebook", user.username);
															
															ApplicationDelegate.currentUser = user;
															
															if (![user objectForKey:@"email"] || ![user objectForKey:@"firstName"] || ![user objectForKey:@"lastName"]) {
																[self fillInformationsFromFacebook];
															}
															
															if ([user objectForKey:@"phoneNumber"] == nil) {
																[self.navigationController pushViewController:[[PhoneNumberViewController alloc] init] animated:YES];
															} else {
																[ApplicationDelegate userIsConnected];
															}
														}
													}];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectAction:(id)sender {
	
}

- (IBAction)subscribeAction:(id)sender {
	
}

- (void)fillInformationsFromFacebook {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"first_name,last_name,email" forKey:@"fields"];

	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			PFUser *user = ApplicationDelegate.currentUser;
			
			if ([result objectForKey:@"first_name"] && ![user objectForKey:@"firstName"]) {
				user[@"firstName"] = [result objectForKey:@"first_name"];
			}
			
			if ([result objectForKey:@"last_name"] && ![user objectForKey:@"lastName"]) {
				user[@"lastName"] = [result objectForKey:@"last_name"];
			}
			
			if ([result objectForKey:@"email"] && ![user objectForKey:@"email"]) {
				user[@"email"] = [result objectForKey:@"email"];
			}
			
			[user saveInBackground];
		}
	}];
}

- (void)getCurrentUser {
	PFQuery *query = [PFUser query];
	[query whereKey:@"gender" equalTo:@"female"]; // find all the women
	NSArray *girls = [query findObjects];
	
	PFUser *user = [PFUser currentUser];
	if (user) {
		[ApplicationDelegate setCurrentUser:user];
	} else {
		[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookProfileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
	}
}

- (void)facebookProfileUpdated:(NSNotification *)notification {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	//	[params setObject:@"id,first_name,picture,email" forKey:@"fields"];
	[params setObject:@"320" forKey:@"width"];
//	[params setObject:@"320" forKey:@"height"];
//	[params setObject:@"large" forKey:@"type"];
	[params setObject:@"false" forKey:@"redirect"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/picture"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		
	}];
	
//	if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"email"]) {
//		
//	}
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
	[self getCurrentUser];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	
}

@end
