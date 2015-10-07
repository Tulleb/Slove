//
//  SLVHomeViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVHomeViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "SLVAddressBookContact.h"
#import "SLVFacebookFriend.h"
#import "SLVContactTableViewCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SLVProfileViewController.h"
#import "SLVSlovedPopupViewController.h"
#import "SLVAddSloverViewController.h"

@interface SLVHomeViewController ()

@end

@implementation SLVHomeViewController

- (void)viewDidLoad {
	self.appName = @"slove";
	
	[super viewDidLoad];
	
	self.searchView.backgroundColor = BLUE;
	
	self.searchTextField.background = [UIImage imageNamed:@"Assets/Box/input_repertoire"];
	self.searchTextField.textColor = BLUE;
	[self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	
	self.searchImageView.image = [UIImage imageNamed:@"Assets/Image/loupe"];
	
	self.pullImageView.image = [UIImage imageNamed:@"Assets/Image/fleche_refresh"];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadContacts) forControlEvents:UIControlEventValueChanged];
	[self.contactTableView addSubview:self.refreshControl];
	
	UIButton *addSloverButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
	[addSloverButton setImage:[UIImage imageNamed:@"Assets/Button/bt_inviter_amis"] forState:UIControlStateNormal];
	[addSloverButton setImage:[UIImage imageNamed:@"Assets/Button/bt_inviter_amis_clic"] forState:UIControlStateHighlighted];
	[addSloverButton addTarget:self action:@selector(showAddSloverView:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *addSloverButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addSloverButton];
	self.navigationItem.rightBarButtonItem = addSloverButtonItem;
	
	// To call viewWillAppear after return from Sloved popup
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didDismissSlovedPopup)
												 name:NOTIFICATION_SLOVED_POPUP_DISMISSED
											   object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (ApplicationDelegate.sloverToSlove) {
		[self.navigationController pushViewController:[[SLVProfileViewController alloc] initWithContact:ApplicationDelegate.sloverToSlove] animated:YES];
		
		ApplicationDelegate.sloverToSlove = nil;
	} else if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		[self startTutorial];
	} else {
		[self loadContacts];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.searchTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)startTutorial {
	if ([ApplicationDelegate.parseConfig objectForKey:PARSE_FIRST_SLOVE_PICTURE]) {
		SLVContact *firstSlover = [[SLVContact alloc] init];
		
		firstSlover.username = [ApplicationDelegate.parseConfig objectForKey:PARSE_FIRST_SLOVE_USERNAME];
		firstSlover.picture = [ApplicationDelegate.parseConfig objectForKey:PARSE_FIRST_SLOVE_PICTURE];
		
		SLVSlovedPopupViewController *slovedPopup = [[SLVSlovedPopupViewController alloc] initWithContact:firstSlover];
		
		[self.navigationController presentViewController:slovedPopup animated:YES completion:nil];
	} else {
		[self performSelector:@selector(startTutorial) withObject:nil afterDelay:5];
	}
}

- (void)didDismissSlovedPopup {
	if (!IS_IOS7) {
		[self viewDidAppear:YES];
	}
}

- (void)needToReloadContacts {
	if (!self.isAlreadyLoading) {
		self.pullTopLayoutConstraint.constant = 150;
		
		[UIView animateWithDuration:LONG_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.pullImageView.alpha = 1;
			[self.view layoutIfNeeded];
		} completion:^(BOOL isFinished) {
			[UIView animateWithDuration:SHORT_ANIMATION_DURATION animations:^{
				self.pullImageView.alpha = 0;
			} completion:^(BOOL isFinished) {
				self.pullTopLayoutConstraint.constant = 8;
				
				[self.view layoutIfNeeded];
			}];
		}];
	}
}

- (void)loadContacts {
	if (!self.isAlreadyLoading) {
		self.isAlreadyLoading = YES;
		
		if (![self.refreshControl isRefreshing]) {
			[self.loadingIndicator startAnimating];
		}
		
		self.synchronizedContacts = [[NSArray alloc] init];
		self.unsynchronizedContacts = [[NSArray alloc] init];
		self.fullSynchronizedContacts = [[NSArray alloc] init];
		self.fullUnsynchronizedContacts = [[NSArray alloc] init];
		self.addressBookContacts = [[NSArray alloc] init];
		self.facebookContacts = [[NSArray alloc] init];
		self.followedContacts = [[NSArray alloc] init];
		
		self.addressBookContactsReady = NO;
		self.facebookContactsReady = NO;
		self.followedContactsReady = NO;
		
		[self checkAddressBookAccessAuthorization];
		[self checkFacebookFriendsAuthorization];
		[self loadFollowedContacts];
		
		[self loadSynchronizedContacts];
	}
}

- (void)checkAddressBookAccessAuthorization {
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		
		[self loadAddressBookFromAddressBookRef:self.addressBookRef];
		[self synchronizeContacts];
		
		return;
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
		SLVLog(@"%@Address book access not granted", SLV_WARNING);
		
		self.addressBookContactsReady = YES;
		
		return;
	} else {
		SLVLog(@"%@Address book access never asked", SLV_WARNING);
		
		if (!([USER_DEFAULTS objectForKey:KEY_ASK_CONTACT_BOOK] && [[USER_DEFAULTS objectForKey:KEY_ASK_CONTACT_BOOK] boolValue]) && !self.popupIsDisplayed) {
			self.popupIsDisplayed = YES;
			
			self.addressBookPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_addressBookAccess", nil) body:NSLocalizedString(@"popup_body_addressBookAccess", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_confirm", nil), nil] andDismissButton:YES];
			
			self.addressBookPopup.delegate = self;
			self.addressBookPopup.priority = kPriorityHigh;
			
			[ApplicationDelegate.queuedPopups addObject:self.addressBookPopup];
			
			[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_CONTACT_BOOK];
		}
		
		self.addressBookContactsReady = YES;
		
		return;
	}
}

- (void)checkFacebookFriendsAuthorization {
	if (![FBSDKAccessToken currentAccessToken]) {
		SLVLog(@"%@Not connected through Facebook", SLV_WARNING);
		
		self.facebookContactsReady = YES;
		
		return;
	}
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/permissions/user_friends"
								  parameters:nil
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			NSArray *data = [result objectForKey:@"data"];
			
			for (NSDictionary *permissionDic in data) {
				if ([[permissionDic objectForKey:@"permission"] isEqualToString:@"user_friends"] && [[permissionDic objectForKey:@"status"] isEqualToString:@"granted"]) {
					[self loadFriends];
					
					return;
				} else {
					SLVLog(@"%@Facebook friends access not granted", SLV_WARNING);
					
					if (!([USER_DEFAULTS objectForKey:KEY_ASK_FACEBOOK_FRIENDS] && [[USER_DEFAULTS objectForKey:KEY_ASK_FACEBOOK_FRIENDS] boolValue]) && !self.popupIsDisplayed) {
						self.popupIsDisplayed = YES;
						
						self.facebookPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_facebookAccess", nil) body:NSLocalizedString(@"popup_body_facebookAccess", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_confirm", nil), nil] andDismissButton:YES];
						
						self.facebookPopup.delegate = self;
						self.facebookPopup.priority = kPriorityHigh;
						
						[ApplicationDelegate.queuedPopups addObject:self.facebookPopup];
						
						[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_FACEBOOK_FRIENDS];
					}
					
					self.facebookContactsReady = YES;
					
					return;
				}
			}
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
	
	// This function sometimes return NO when it shouldn't
//	return ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]);
}

- (void)showSettingManipulation {
	SLVInteractionPopupViewController *popupViewController = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_go_to_settings", nil) buttonsTitle:nil andDismissButton:YES];
	
	[self.navigationController presentViewController:popupViewController animated:YES completion:nil];
}

- (void)askAddressBookAccess {
	self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
		SLVLog(@"%@Address book access not granted", SLV_WARNING);
		
		[self showSettingManipulation];
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
		SLVLog(@"Asking address book access to the user");
		ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
			if (granted) {
				SLVLog(@"User have granted access to his contact list");
				
				[self needToReloadContacts];
			} else {
				SLVLog(@"%@User didn't grant access to his contact list", SLV_WARNING);
			}
		});
	}
}

- (void)askFacebookFriends {
	FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
	[loginManager logInWithReadPermissions:[NSArray arrayWithObjects:@"user_friends", nil] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
		if (!error) {
			if ([result.grantedPermissions containsObject:@"user_friends"]) {
				SLVLog(@"User have granted access to his friend list");
				
				[self needToReloadContacts];
			} else {
				SLVLog(@"%@User didn't grant access to his friend list", SLV_WARNING);
			}
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

- (void)loadAddressBookFromAddressBookRef:(ABAddressBookRef)addressBookRef {
	SLVLog(@"Loading user contacts from his address book");
	
	NSMutableArray *addressBookBuffer = [[NSMutableArray alloc] init];
	
	CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
	CFIndex contactCount = ABAddressBookGetPersonCount(addressBookRef);
	
	for (int i = 0; i < contactCount; i++) {
		ABRecordRef contact = CFArrayGetValueAtIndex(contacts, i);
		CFTypeRef firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
		CFTypeRef lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty);
		CFTypeRef organization = ABRecordCopyValue(contact, kABPersonOrganizationProperty);
		NSString *firstNameString = (NSString *)CFBridgingRelease(firstName);
		NSString *lastNameString = (NSString *)CFBridgingRelease(lastName);
		NSString *organizationString = (NSString *)CFBridgingRelease(organization);
		
		NSString *fullName = @"";
		if (firstName) {
			fullName = [fullName stringByAppendingString:firstNameString];
		}
		if (lastNameString) {
			if (![fullName isEqualToString:@""]) {
				fullName = [fullName stringByAppendingString:@" "];
			}
			
			fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@"%@", lastNameString]];
		}
		if (organizationString) {
			if (![fullName isEqualToString:@""]) {
				fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" (%@)", organizationString]];
			} else {
				fullName = [fullName stringByAppendingString:organizationString];
			}
		}
		
		if (![fullName isEqualToString:@""]) {
			CFDataRef imageData = ABPersonCopyImageData(contact);
			UIImage *image = [UIImage imageWithData:(NSData *)CFBridgingRelease(imageData)];
			
			NSMutableArray *phoneNumbersString = [[NSMutableArray alloc] init];
			
			ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
			CFIndex phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
			
			if (phoneNumberCount > 0) {
				for (int j = 0; j < phoneNumberCount; j++) {
					CFTypeRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
					NSString *phoneNumberString = (NSString *)CFBridgingRelease(phoneNumber);
					
					NSMutableDictionary *phoneNumberDic = [[NSMutableDictionary alloc] init];
					
					[phoneNumberDic setObject:phoneNumberString forKey:@"phoneNumber"];
					[phoneNumberDic setObject:[SLVTools formatPhoneNumber:phoneNumberString withCountryCodeData:ApplicationDelegate.userCountryCodeData] forKey:@"formatedPhoneNumber"];
					
					[phoneNumbersString addObject:[NSDictionary dictionaryWithDictionary:phoneNumberDic]];
				}
				
				SLVAddressBookContact *cachedContact = [[SLVAddressBookContact alloc] init];
				cachedContact.phoneNumbers = phoneNumbersString;
				cachedContact.fullName = fullName;
				if (image) {
					cachedContact.picture = image;
				} else {
					cachedContact.picture = [UIImage imageNamed:@"Assets/Avatar/avatar_user_big"];
				}
				
				[addressBookBuffer addObject:cachedContact];
			}
		}
	}
	
	self.unsynchronizedContacts = [addressBookBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
	self.fullUnsynchronizedContacts = self.unsynchronizedContacts;
}

- (void)loadFriends {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"5000" forKey:@"limit"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/friends?fields=name,picture.width(320)"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			NSMutableArray *friends = [[NSMutableArray alloc] init];
			NSArray *data = [result objectForKey:@"data"];
			
			for (NSDictionary *friendDic in data) {
				NSString *facebookId = [friendDic objectForKey:@"id"];
				NSString *name = [friendDic objectForKey:@"name"];
				NSString *pictureURLString;
				
				NSDictionary *pictureDic = [friendDic objectForKey:@"picture"];
				if (pictureDic) {
					NSDictionary *pictureData = [pictureDic objectForKey:@"data"];
					if (pictureData) {
						pictureURLString = [pictureData objectForKey:@"url"];
					}
				}
				
				if (facebookId && name) {
					SLVFacebookFriend *friend = [[SLVFacebookFriend alloc] init];
					friend.facebookId = facebookId;
					friend.fullName = name;
					
					for (SLVFacebookFriend *recordedFriend in friends) {
						if ([friend.fullName isEqualToString:recordedFriend.fullName]) {
							friend = recordedFriend;
							[friends removeObject:friend];
							
							break;
						}
					}
					
					if (pictureURLString) {
						friend.pictureURLString = pictureURLString;
					}
					
					UIImage *previousPicture = [SLVTools loadImageWithName:friend.fullName];
					if (!previousPicture) {
						if (pictureURLString) {
							if (![pictureURLString isEqualToString:friend.pictureURLString]) {
								friend.pictureDownloaded = NO;
							}
						} else {
							friend.picture = [UIImage imageNamed:@"Assets/Avatar/avatar_user_big"];
							friend.pictureDownloaded = YES;
						}
					} else {
						friend.picture = previousPicture;
						friend.pictureDownloaded = YES;
					}
					
					[friends addObject:friend];
				}
			}
			
			self.facebookContacts = [NSArray arrayWithArray:friends];
			
			[self synchronizeFriends];
			[self downloadPictures];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			
			self.facebookContactsReady = YES;
		}
	}];
}

- (void)loadFollowedContacts {
	[PFCloud callFunctionInBackground:SYNCHRONIZE_FOLLOWED_CONTACTS_FUNCTION
					   withParameters:nil
								block:^(id object, NSError *error){
									if (!error) {
										NSDictionary *datas = object;
										NSArray *follows = [datas objectForKey:@"follows"];
										
										if (follows && [follows count] > 0) {
											NSMutableArray *followedContactsBuffer = [[NSMutableArray alloc] init];
											
											for (NSDictionary *user in follows) {
												SLVContact *contact = [[SLVContact alloc] init];
												
												contact.username = [user objectForKey:@"username"];
												
												NSString *pictureUrl = [user objectForKey:@"pictureUrl"];
												if (pictureUrl) {
													contact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
												} else {
													contact.picture = [UIImage imageNamed:@"Assets/Avatar/avatar_user"];
												}
												
												NSString *fullName = @"";
												NSString *firstName = [user objectForKey:@"firstName"];
												
												if (firstName) {
													fullName = [fullName stringByAppendingString:firstName];
												}
												
												NSString *lastName = [user objectForKey:@"lastName"];
												
												if (lastName) {
													if (![fullName isEqualToString:@""]) {
														fullName = [fullName stringByAppendingString:@" "];
													}
													
													fullName = [fullName stringByAppendingString:lastName];
												}
												
												contact.fullName = fullName;
												
												[followedContactsBuffer addObject:contact];
											}
											
											self.followedContacts = [NSArray arrayWithArray:followedContactsBuffer];
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
									
									self.followedContactsReady = YES;
								}];
}

- (void)loadSynchronizedContacts {
	if (!(self.addressBookContactsReady && self.facebookContactsReady && self.followedContactsReady)) {
		// TODO: fix issue that stop the performSelector when called from soloButtonPressed:
		
		[self performSelector:@selector(loadSynchronizedContacts) withObject:nil afterDelay:1];
		
		return;
	}
	
	[self addContactsToSynchronizedContacts:self.addressBookContacts];
	[self addContactsToSynchronizedContacts:self.facebookContacts];
	[self addContactsToSynchronizedContacts:self.followedContacts];
	
	self.fullSynchronizedContacts = self.synchronizedContacts;
	
	if (![self.refreshControl isRefreshing]) {
		[self.loadingIndicator stopAnimating];
	}
	
	[self.contactTableView reloadData];
	
	if ([self.refreshControl isRefreshing]) {
		[self.refreshControl endRefreshing];
	}
	
	self.isAlreadyLoading = NO;
}

- (void)addContactsToSynchronizedContacts:(NSArray *)contactsToAdd {
	NSMutableArray *synchronizedContactsBuffer = [NSMutableArray arrayWithArray:self.synchronizedContacts];
	
	for (SLVContact *contactToAdd in contactsToAdd) {
		BOOL shouldAddContact = YES;
		
		for (SLVContact *contact in self.synchronizedContacts) {
			if ([contactToAdd.username isEqualToString:contact.username]) {
				shouldAddContact = NO;
				break;
			}
		}
		
		if (shouldAddContact) {
			[synchronizedContactsBuffer addObject:contactToAdd];
		}
	}
	
	self.synchronizedContacts = [synchronizedContactsBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.username caseInsensitiveCompare:b.username];
	}];
}

- (void)downloadPictures {
	BOOL downloadNeeded = NO;
	
	for (SLVContact *contact in self.synchronizedContacts) {
		if ([contact isKindOfClass:[SLVFacebookFriend class]]) {
			SLVFacebookFriend *friend = (SLVFacebookFriend *)contact;
			
			if (!friend.pictureDownloaded) {
				downloadNeeded = YES;
				break;
			}
		}
	}
	
	if (!downloadNeeded) {
		return;
	}
	
	self.loadingLabel.hidden = NO;
	int previousPercentage = -1;
	
	for (SLVContact *contact in self.synchronizedContacts) {
		if ([contact isKindOfClass:[SLVFacebookFriend class]]) {
			SLVFacebookFriend *friend = (SLVFacebookFriend *)contact;
			
			if (!friend.pictureDownloaded) {
				int percentage = (int)((([self.synchronizedContacts indexOfObject:friend] + 1) / (float)([self.synchronizedContacts count])) * 100);
				if ((percentage % 10 == 0) && (percentage != previousPercentage)) {
					previousPercentage = percentage;
					SLVLog(@"Loading contact... %d%%", percentage);
				}
				
				self.loadingLabel.text = [NSString stringWithFormat:@"%@ %d%%", NSLocalizedString(@"label_loading", nil), percentage];
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantPast]];
				
				UIImage *picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:friend.pictureURLString]]];
				[SLVTools saveImage:picture withName:friend.fullName];
				friend.picture = picture;
				
				friend.pictureDownloaded = YES;
			}
		}
	}
	
	self.loadingLabel.hidden = YES;
}

- (void)synchronizeContacts {
	if ([self.unsynchronizedContacts count] == 0) {
		self.addressBookContactsReady = YES;
		
		return;
	}
	
	NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
	
	for (SLVAddressBookContact *addressBookContact in self.unsynchronizedContacts) {
		for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
			[phoneNumbers addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
		}
	}
	
	[PFCloud callFunctionInBackground:SYNCHRONIZE_ADDRESS_BOOK_CONTACTS_FUNCTION
					   withParameters:@{@"phoneNumbers" : phoneNumbers}
								block:^(id object, NSError *error){
									if (!error) {
										NSDictionary *datas = object;
										NSArray *registeredContacts = [datas objectForKey:@"registeredContacts"];
										
										if (registeredContacts && [registeredContacts count] > 0) {
											NSMutableArray *addressBookContactsBuffer = [[NSMutableArray alloc] init];
											
											for (NSDictionary *registeredContact in registeredContacts) {
												NSString *username = [registeredContact objectForKey:@"username"];
												
												if (![username isEqualToString:[PFUser currentUser].username]) {
													for (SLVAddressBookContact *addressBookContact in self.unsynchronizedContacts) {
														for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
															if ([[phoneNumberDic objectForKey:@"formatedPhoneNumber"] isEqualToString:[registeredContact objectForKey:@"phoneNumber"]]) {
																addressBookContact.username = username;
																
																NSString *pictureUrl = [registeredContact objectForKey:@"pictureUrl"];
																if (pictureUrl && ![pictureUrl isEqualToString:@""]) {
																	addressBookContact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
																}
																
																SLVLog(@"Contact '%@' synchronized with username '%@'", addressBookContact.fullName, addressBookContact.username);
																
																[addressBookContactsBuffer addObject:addressBookContact];
																
																[self removeContactFromUnsynchronizedContacts:addressBookContact];
															}
														}
													}
												}
											}
											
											self.addressBookContacts = addressBookContactsBuffer;
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
									
									self.addressBookContactsReady = YES;
								}];
}

- (void)synchronizeFriends {
	if ([self.facebookContacts count] == 0) {
		self.facebookContactsReady = YES;
		
		return;
	}
	
	NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
	
	for (SLVFacebookFriend *friend in self.facebookContacts) {
		if (friend.facebookId) {
			[facebookIds addObject:friend.facebookId];
		}
	}
	
	[PFCloud callFunctionInBackground:SYNCHRONIZE_FACEBOOK_CONTACTS_FUNCTION
					   withParameters:@{@"facebookIds" : facebookIds}
								block:^(id object, NSError *error){
									if (!error) {
										NSDictionary *datas = object;
										NSArray *registeredContacts = [datas objectForKey:@"registeredFriends"];
										
										if (registeredContacts && [registeredContacts count] > 0) {
											for (NSDictionary *registeredContact in registeredContacts) {
												NSString *username = [registeredContact objectForKey:@"username"];
												
												if (![username isEqualToString:[PFUser currentUser].username]) {
													
													for (SLVFacebookFriend *friend in self.facebookContacts) {
														if ([friend.facebookId isEqualToString:[registeredContact objectForKey:@"facebookId"]]) {
															friend.username = username;
															
															NSString *pictureURLString = [registeredContact objectForKey:@"pictureUrl"];
															
															if (pictureURLString && ![pictureURLString isEqualToString:@""]) {
																if (![pictureURLString isEqualToString:friend.pictureURLString]) {
																	friend.pictureURLString = pictureURLString;
																	friend.pictureDownloaded = NO;
																} else {
																	UIImage *previousPicture = [SLVTools loadImageWithName:friend.fullName];
																	if (!previousPicture) {
																		friend.pictureDownloaded = NO;
																	} else {
																		friend.picture = previousPicture;
																		friend.pictureDownloaded = YES;
																	}
																}
															}
															
															SLVLog(@"Contact '%@' synchronized with username '%@'", friend.fullName, friend.username);
														}
													}
												}
											}
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
									
									self.facebookContactsReady = YES;
								}];
}

- (void)removeContactFromUnsynchronizedContacts:(SLVContact *)contact {
	NSMutableArray *unsynchronizedContactsBuffer = [NSMutableArray arrayWithArray:self.unsynchronizedContacts];
	[unsynchronizedContactsBuffer removeObject:contact];
	self.unsynchronizedContacts = [NSArray arrayWithArray:unsynchronizedContactsBuffer];
	self.fullUnsynchronizedContacts = self.unsynchronizedContacts;
}

- (void)showAddSloverView:(UIButton *)button {
	SLVAddSloverViewController *addSloverViewController = [[SLVAddSloverViewController alloc] initWithHomeViewController:self];
	
	[self.navigationController pushViewController:addSloverViewController animated:YES];
}

- (void)inviteAction:(UIButton *)button {
	SLVLog(@"User is trying to share Slove!");
	
	NSString *shareText = NSLocalizedString(@"label_share_with_friends", nil);
	UIImage *shareImage = [UIImage imageNamed:@"Assets/App Icon/Logo_Slove_App_1024"];
	NSURL *shareUrl = [NSURL URLWithString:[ApplicationDelegate.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL]];
	
	UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[shareText, shareImage, shareUrl] applicationActivities:nil];
	
	NSMutableArray *excludedActivityTypes = [NSMutableArray arrayWithObjects:UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, nil];
	
	if (IS_SUP_IOS9) {
		[excludedActivityTypes addObject:UIActivityTypeOpenInIBooks];
	}
	
	activityViewController.excludedActivityTypes = excludedActivityTypes;
	
	[self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)inviteBySMS:(UIButton *)button {
	SLVAddressBookContact *addressBookContact = [self.unsynchronizedContacts objectAtIndex:button.tag];
	
	if(![MFMessageComposeViewController canSendText]) {
		SLVLog(@"%@This device can't send SMS", SLV_WARNING);
		
		if (!self.popupIsDisplayed) {
			self.popupIsDisplayed = YES;
		
			SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_smsInvite", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_ok", nil), nil] andDismissButton:NO];
			
			errorPopup.delegate = self;
			
			[self presentViewController:errorPopup animated:YES completion:nil];
		}
		
		return;
	}
	
	NSMutableArray *recipents = [[NSMutableArray alloc] init];
	for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
		[recipents addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
	}
	
	NSString *message = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"label_smsInvite", nil), [ApplicationDelegate.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL]];
	
	MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
	messageController.messageComposeDelegate = self;
	[messageController setRecipients:recipents];
	[messageController setBody:message];
	
	[self presentViewController:messageController animated:YES completion:nil];
}

- (SLVContact *)contactForUsername:(NSString *)username {
	for (SLVContact *contact in self.fullSynchronizedContacts) {
		if ([contact.username isEqualToString:username]) {
			return contact;
		}
	}
	
	return nil;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.synchronizedContacts count] > 0) {
		return 2;
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([self.synchronizedContacts count] > 0) {
		if (section == 0) {
			return NSLocalizedString(@"section_slovers", nil);
		} else {
			return NSLocalizedString(@"section_invite_on_slove", nil);
		}
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([self.synchronizedContacts count] > 0) {
		return 1 * 2 + 30;
	} else {
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (([self.synchronizedContacts count] > 0) && (section == 0)) {
		return [self.synchronizedContacts count];
	}
	return [self.unsynchronizedContacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ContactCell";
	SLVContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"SLVContactTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	}
	
	[SLVViewController setStyle:cell];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.subtitleImageView.image = [UIImage imageNamed:@"Assets/Image/coeur_rouge"];
	[cell.selectionButton setBackgroundImage:[UIImage imageNamed:@"Assets/Image/fleche_go_profil"] forState:UIControlStateNormal];
	cell.subtitleLabel.textColor = BLUE;
	
	SLVContact *contact;
	BOOL isSynchronized = NO;
	
	if (indexPath.section == 0 && [self.synchronizedContacts count] > 0) {
		contact = [self.synchronizedContacts objectAtIndex:indexPath.row];
		isSynchronized = YES;
	} else if ([self.unsynchronizedContacts count] > 0) {
		contact = [self.unsynchronizedContacts objectAtIndex:indexPath.row];
		cell.subtitleImageView.image = nil;
		cell.subtitleLabel.textColor = nil;
		[cell.selectionButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_ajout_contact"] forState:UIControlStateNormal];
		cell.selectionButton.tag = indexPath.row;
		[cell.selectionButton addTarget:self action:@selector(inviteAction:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		return cell;
	}
	
	if (!contact) {
		return cell;
	}
	
	if (isSynchronized) {
		cell.titleLabel.text = contact.fullName;
		
		cell.subtitleLabel.text = contact.username;
		cell.subtitleLabel.textColor = BLUE;
	} else {
		cell.titleLabel.text = contact.fullName;
		
		if ([contact isKindOfClass:[SLVAddressBookContact class]]) {
			SLVAddressBookContact *addressBookContact = (SLVAddressBookContact *)contact;
			
			if ([addressBookContact.phoneNumbers count] > 1) {
				cell.subtitleLabel.text = NSLocalizedString(@"label_several_phone_numbers", nil);
			} else {
				NSDictionary *phoneNumberDic = [addressBookContact.phoneNumbers firstObject];
				NSString *formatedPhoneNumber = [phoneNumberDic objectForKey:@"formatedPhoneNumber"];
				NSString *phoneNumber = [phoneNumberDic objectForKey:@"phoneNumber"];
				
				if (formatedPhoneNumber && [formatedPhoneNumber length] >= 6) {
					if ([[formatedPhoneNumber substringToIndex:5] isEqualToString:@"error"]) {
						cell.subtitleLabel.text = NSLocalizedString(formatedPhoneNumber, nil);
						
						SLVLog(@"%@Phone number '%@' couldn't be formated with country code '%@'", SLV_ERROR, phoneNumber, ApplicationDelegate.userCountryCodeData);
					} else {
						cell.subtitleLabel.text = phoneNumber;
					}
				} else {
					cell.subtitleLabel.text = NSLocalizedString(formatedPhoneNumber, nil);
					
					SLVLog(@"%@Formated phone number reception for '%@' failed without displaying an error!", SLV_ERROR, phoneNumber);
				}
			}
		} else if ([contact isKindOfClass:[SLVFacebookFriend class]]) {
			cell.subtitleLabel.text = @"";
		}
	}
	
	cell.pictureImageView.image = contact.picture;
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.clipsToBounds = YES;
	
	cell.layerImageView.image = [UIImage imageNamed:@"Assets/Layer/masque_profil_repertoire"];
	
	cell.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_LARGE];
	
	cell.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT size:DEFAULT_FONT_SIZE];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SLVContact *contact;
	
	if (indexPath.section == 0 && [self.synchronizedContacts count] > 0) {
		contact = [self.synchronizedContacts objectAtIndex:indexPath.row];
	} else {
		return;
	}
	
	SLVLog(@"Selected %@", [contact description]);
	
	[self.navigationController pushViewController:[[SLVProfileViewController alloc] initWithContact:contact] animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, [self tableView:tableView heightForHeaderInSection:section])];
	headerView.backgroundColor = VERY_LIGHT_GRAY;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 1, headerView.frame.size.width - 8 * 2, headerView.frame.size.height - 1 * 2)];
	label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.textColor = DARK_GRAY;
	
	[headerView addSubview:label];
	
	return headerView;
}


#pragma mark - SLVInteractionPopupDelegate

- (void)soloButtonPressed:(SLVInteractionPopupViewController *)popup {
	self.popupIsDisplayed = NO;
	
	if (popup == self.addressBookPopup) {
		[self askAddressBookAccess];
	} else if (popup == self.facebookPopup) {
		[self askFacebookFriends];
	}
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField {
	if (textField == self.searchTextField) {
		NSString *text = textField.text;
		
		if(text.length == 0) {
			self.unsynchronizedContacts = self.fullUnsynchronizedContacts;
			self.synchronizedContacts = self.fullSynchronizedContacts;
		} else {
			NSMutableArray *filteredContacts = [[NSMutableArray alloc] init];
			
			for (SLVAddressBookContact *contact in self.fullSynchronizedContacts) {
				NSRange fullNameRange = [contact.fullName rangeOfString:text options:NSCaseInsensitiveSearch];
				NSRange usernameRange = [contact.username rangeOfString:text options:NSCaseInsensitiveSearch];
				if(fullNameRange.location != NSNotFound || usernameRange.location != NSNotFound) {
					[filteredContacts addObject:contact];
				}
			}
			
			self.synchronizedContacts = filteredContacts;
			
			filteredContacts = [[NSMutableArray alloc] init];
			
			for (SLVAddressBookContact *contact in self.fullUnsynchronizedContacts) {
				NSRange fullNameRange = [contact.fullName rangeOfString:text options:NSCaseInsensitiveSearch];
				if(fullNameRange.location != NSNotFound) {
					[filteredContacts addObject:contact];
				}
			}
			
			self.unsynchronizedContacts = filteredContacts;
		}
		
		[self.contactTableView reloadData];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

@end
