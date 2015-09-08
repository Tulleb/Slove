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
#import "SLVPhoneNumberViewController.h"
#import "SLVRegisterViewController.h"
#import "SLVLogInViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface SLVConnectionViewController ()

@end

@implementation SLVConnectionViewController

- (void)viewDidLoad {
	self.appName = @"connection";
	
	[super viewDidLoad];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
	self.subtitleUpperLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	self.subtitleLowerLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_LARGE];
	self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
	
	self.backgroundImageView.image = [UIImage imageNamed:@"Assets/Image/image_fond"];
	self.layerImageView.image = [UIImage imageNamed:@"Assets/Image/masque_coeur_slovy"];
	
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	// This block doesn't trigger when there is no Internet connexion
	[[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
		if (!error) {
			if ([FBSDKAccessToken currentAccessToken]) {
				[self loggedWithFacebook];
			} else if ([PFUser currentUser]) {
				[self loggedWithoutFacebook];
			}
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
	
	if (![SLVTools checkConnection]) {
		// TODO: exit app
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_facebook"] forState:UIControlStateNormal];
	[self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_facebook_clic"] forState:UIControlStateHighlighted];
	[self.facebookLoginButton setImage:nil forState:UIControlStateNormal];
	[self.facebookLoginButton setImage:nil forState:UIControlStateHighlighted];
	
	self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = NO;
	
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectAction:(id)sender {
	[self.navigationController pushViewController:[[SLVLogInViewController alloc] init] animated:YES];
}

- (IBAction)registerAction:(id)sender {
	[self.navigationController pushViewController:[[SLVRegisterViewController alloc] init] animated:YES];
}

- (void)loggedWithFacebook {
	FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
	if (accessToken) {
		[FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookProfileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
		
		[PFFacebookUtils logInInBackgroundWithAccessToken:accessToken
													block:^(PFUser *user, NSError *error) {
														if (error) {
															SLVLog(@"%@%@", SLV_ERROR, error.description);
															[ParseErrorHandlingController handleParseError:error];
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
																		[ParseErrorHandlingController handleParseError:error];
																	}
																	
																	validUsername = ![self usernameIsUndefined];
																}];
															} else {
																validUsername = ![self usernameIsUndefined];
															}
															
															if (!validUsername) {
																SLVLog(@"%@Username is not valid, going to Username view controller", SLV_WARNING);
																[self.navigationController pushViewController:[[SLVUsernameViewController alloc] init] animated:YES];
															} else if ([user objectForKey:@"phoneNumber"] == nil || [[user objectForKey:@"phoneNumber"] isEqualToString:@""]) {
																[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
															} else {
																[ApplicationDelegate userConnected];
															}
														}
													}];
	}
}

- (void)loggedWithoutFacebook {
	PFUser *user = [PFUser currentUser];
	if ([user objectForKey:@"phoneNumber"] == nil) {
		[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
	} else {
		[ApplicationDelegate userConnected];
	}
}

- (void)getInformationsFromFacebook {
	PFUser *user = [PFUser currentUser];
	
	if ([[user objectForKey:@"facebookId"] length] == 0 || [[user objectForKey:@"email"] length] == 0 || [[user objectForKey:@"firstName"] length] == 0 || [[user objectForKey:@"lastName"] length] == 0) {
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

	[params setObject:@"first_name, last_name, email" forKey:@"fields"];

	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			PFUser *user = [PFUser currentUser];
			
			if ([result objectForKey:@"id"]) {
				if ([[user objectForKey:@"facebookId"] length] == 0) {
					user[@"facebookId"] = [result objectForKey:@"id"];
					SLVLog(@"User's Facebook ID retrieved from Facebook");
				} else {
					SLVLog(@"User already has a Facebook ID recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's Facebook ID", SLV_WARNING);
			}
			
			if ([result objectForKey:@"first_name"]) {
				if ([[user objectForKey:@"firstName"] length] == 0) {
					user[@"firstName"] = [result objectForKey:@"first_name"];
					SLVLog(@"User's first name retrieved from Facebook");
				} else {
					SLVLog(@"User already has a first name recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's first name", SLV_WARNING);
			}
			
			if ([result objectForKey:@"last_name"]) {
				if ([[user objectForKey:@"lastName"] length] == 0) {
					user[@"lastName"] = [result objectForKey:@"last_name"];
					SLVLog(@"User's last name retrieved from Facebook");
				} else {
					SLVLog(@"User already has a last name recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's last name", SLV_WARNING);
			}
			
			if ([result objectForKey:@"email"]) {
				if ([[user objectForKey:@"email"] length] == 0) {
					user[@"email"] = [result objectForKey:@"email"];
					SLVLog(@"User's email retrieved from Facebook");
				} else {
					SLVLog(@"User already has an email recorded in Slove");
				}
			} else {
				SLVLog(@"%@Can't access Facebook user's email", SLV_WARNING);
			}
			
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error) {
					SLVLog(@"%@%@", SLV_ERROR, error.description);
					[ParseErrorHandlingController handleParseError:error];
				}
			}];
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
						
						[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
							if (error) {
								SLVLog(@"%@%@", SLV_ERROR, error.description);
								[ParseErrorHandlingController handleParseError:error];
							}
						}];
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
	if ([PFUser currentUser]) {
		[self getInformationsFromFacebook];
	}
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
	[PFUser logOutInBackgroundWithBlock:^(NSError *error) {
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

@end
