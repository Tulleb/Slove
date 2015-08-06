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
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:45];
	self.subtitleLowerLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	
	[[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
		if (!error) {
			self.facebookLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
			
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
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	ApplicationDelegate.currentNavigationController.navigationBarHidden = YES;
	
	[self animateLogoEntrance];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	ApplicationDelegate.currentNavigationController.navigationBarHidden = NO;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	CGFloat bodyViewHeight = SCREEN_HEIGHT - self.footerViewHeightConstraint.constant;
	
	self.logoViewHeightConstraint.constant = bodyViewHeight * 0.7;
	self.subtitleViewHeightConstraint.constant = bodyViewHeight * 0.3;
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

- (void)animateLogoEntrance {
	NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], CONNECTION_VIEW_SOUND];
	NSURL *soundUrl = [NSURL fileURLWithPath:path];
	
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
	[audioPlayer play];
	SLVLog(@"Playing sound: %@", CONNECTION_VIEW_SOUND);
	
//	CGRect logoImageViewFrame = self.logoImageView.frame;
//	CGPoint logoImageViewCenter = self.logoImageView.center;
//	
//	self.logoImageView.frame = CGRectMake(logoImageViewCenter.x, logoImageViewCenter.y, 1, 1);
//	self.logoImageView.backgroundColor = GREEN;
//	
//	[UIView transitionWithView:self.logoImageView
//					  duration:10
//					   options:UIViewAnimationOptionCurveEaseIn
//					animations:^{
//						self.logoImageView.frame = logoImageViewFrame;
//					}
//					completion:nil];
}

- (void)animateImages {
	self.logoImageView.animationImages = [NSArray arrayWithObjects:
										  [UIImage imageNamed:@"anim_logo00@3x.png"],
										  [UIImage imageNamed:@"anim_logo01@3x.png"],
										  [UIImage imageNamed:@"anim_logo02@3x.png"],
										  [UIImage imageNamed:@"anim_logo03@3x.png"],
										  [UIImage imageNamed:@"anim_logo04@3x.png"],
										  [UIImage imageNamed:@"anim_logo05@3x.png"],
										  [UIImage imageNamed:@"anim_logo06@3x.png"],
										  [UIImage imageNamed:@"anim_logo07@3x.png"],
										  [UIImage imageNamed:@"anim_logo08@3x.png"],
										  [UIImage imageNamed:@"anim_logo09@3x.png"],
										  [UIImage imageNamed:@"anim_logo10@3x.png"],
										  [UIImage imageNamed:@"anim_logo11@3x.png"],
										  [UIImage imageNamed:@"anim_logo12@3x.png"],
										  [UIImage imageNamed:@"anim_logo13@3x.png"],
										  [UIImage imageNamed:@"anim_logo14@3x.png"],
										  [UIImage imageNamed:@"anim_logo15@3x.png"],
										  [UIImage imageNamed:@"anim_logo16@3x.png"],
										  [UIImage imageNamed:@"anim_logo17@3x.png"],
										  [UIImage imageNamed:@"anim_logo18@3x.png"],
										  [UIImage imageNamed:@"anim_logo19@3x.png"],
										  [UIImage imageNamed:@"anim_logo20@3x.png"],
										  [UIImage imageNamed:@"anim_logo21@3x.png"],
										  [UIImage imageNamed:@"anim_logo22@3x.png"],
										  [UIImage imageNamed:@"anim_logo23@3x.png"], nil];
	
	self.logoImageView.animationDuration = 1;
	self.logoImageView.animationRepeatCount = 0;
	[self.logoImageView startAnimating];
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
