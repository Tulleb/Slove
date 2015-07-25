//
//  SLVConnectionViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVConnectionViewController.h"
#import "SLVUsernameViewController.h"
#import "SLVHomeViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface SLVConnectionViewController ()

@end

@implementation SLVConnectionViewController

- (void)viewDidLoad {
	self.appName = @"Connection";
	
	[super viewDidLoad];
	
	self.facebookLoginButton.readPermissions = @[@"public_profile", @"email"];
	
	if ([FBSDKAccessToken currentAccessToken]) {
		[self loggedWithFacebook];
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

- (void)loggedWithFacebook {
	FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
	if (accessToken) {
		[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookProfileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
		
		[PFFacebookUtils logInInBackgroundWithAccessToken:accessToken
													block:^(PFUser *user, NSError *error) {
														if (!user) {
															SLVLog(@"%@Can't log in with Facebook", SLV_ERROR);
														} else {
															SLVLog(@"User '%@' logged in through Facebook", user.username);
															
															[self getInformationsFromFacebook];
															
															__block BOOL validUsername = NO;
															
															if (user.isNew) {
																SLVLog(@"New user! Erasing his default token username");
																user[@"username"] = [NSString stringWithFormat:@"%@%@", USERNAME_EMPTY_PREFIX, user.username];
																[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
																	if (error) {
																		SLVLog(@"%@%@", SLV_ERROR, error.description);
																	}
																	
																	validUsername = ![self usernameIsUndefined];
																}];
															} else {
																validUsername = ![self usernameIsUndefined];
															}
															
															if (!validUsername) {
																SLVLog(@"%@Username is not valid, going to Username view controller", SLV_WARNING);
																[self.navigationController pushViewController:[[SLVUsernameViewController alloc] init] animated:YES];
															} else {
																[ApplicationDelegate userIsConnected];
															}
														}
													}];
	}
}

- (void)getInformationsFromFacebook {
	PFUser *user = [PFUser currentUser];
	
	if (![user objectForKey:@"email"] || ![user objectForKey:@"firstName"] || ![user objectForKey:@"lastName"]) {
		SLVLog(@"Trying to get some account information from Facebook...");
		[self getPublicInformationsFromFacebook];
	}
	
	if (![user objectForKey:@"pictureUrl"]) {
		SLVLog(@"Trying to get profile picture from Facebook...");
		[self getProfilePictureFromFacebook];
	}
}

- (void)getPublicInformationsFromFacebook {
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
			PFUser *user = [PFUser currentUser];
			
			if ([result objectForKey:@"first_name"]) {
				if (![user objectForKey:@"firstName"]) {
					user[@"firstName"] = [result objectForKey:@"first_name"];
					SLVLog(@"User's first name retrieved from Facebook");
				} else {
					SLVLog(@"User already has a first name recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's first name", SLV_WARNING);
			}
			
			if ([result objectForKey:@"last_name"]) {
				if (![user objectForKey:@"lastName"]) {
					user[@"lastName"] = [result objectForKey:@"last_name"];
					SLVLog(@"User's last name retrieved from Facebook");
				} else {
					SLVLog(@"User already has a last name recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's last name", SLV_WARNING);
			}
			
			if ([result objectForKey:@"email"]) {
				if (![user objectForKey:@"email"]) {
					user[@"email"] = [result objectForKey:@"email"];
					SLVLog(@"User's email retrieved from Facebook");
				} else {
					SLVLog(@"User already has an email recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's email", SLV_WARNING);
			}
			
			[user saveInBackground];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}

- (void)getProfilePictureFromFacebook {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"320" forKey:@"height"];
	[params setObject:@"320" forKey:@"width"];
	[params setObject:@"false" forKey:@"redirect"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/picture"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result && [result objectForKey:@"data"]) {
			NSDictionary *data = [result objectForKey:@"data"];
			if (data && [data objectForKey:@"url"]) {
				NSString *url = [data objectForKey:@"url"];
				
				if (url) {
					PFUser *user = [PFUser currentUser];
					
					if (![user objectForKey:@"pictureUrl"]) {
						user[@"pictureUrl"] = url;
						SLVLog(@"User's profile picture retrieved from Facebook");
						
						[user saveInBackground];
					} else {
						SLVLog(@"User already has a picture profile recorded in Slove");
					}
				} else {
					SLVLog(@"%@Can't access Facebook profile picture URL", SLV_WARNING);
				}
			} else {
				SLVLog(@"%@Can't access Facebook profile picture data", SLV_WARNING);
			}
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}

- (void)facebookProfileUpdated:(NSNotification *)notification {
	[self getInformationsFromFacebook];
}

- (BOOL)usernameIsUndefined {
	PFUser *user = [PFUser currentUser];
	
	NSString *username = [user objectForKey:@"username"];
	if ([username length] < [USERNAME_EMPTY_PREFIX length]) {
		return NO;
	}
	
	NSString *usernamePrefix = [username substringToIndex:[USERNAME_EMPTY_PREFIX length]];
	return ([usernamePrefix isEqualToString:USERNAME_EMPTY_PREFIX]);
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
	[self loggedWithFacebook];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
	SLVLog(@"User '%@' logged out through Facebook", [PFUser currentUser].username);
	[PFUser logOutInBackground];
}

@end
