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
#import "SLVContactViewController.h"
#import "SLVSlovedPopupViewController.h"
#import "SLVAddSloverViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#define TABLE_CELL_HEIGHT	70

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
	[self.refreshControl addTarget:self action:@selector(reloadContacts) forControlEvents:UIControlEventValueChanged];
	[self.contactTableView addSubview:self.refreshControl];
	
	self.tutorialBubbleImageView.image = [UIImage imageNamed:@"Assets/Image/infobulle_tuto"];
	self.tutorialBubbleLabel.text = [self.tutorialBubbleLabel.text stringByReplacingOccurrencesOfString:@"[count]" withString:[[[PFUser currentUser] objectForKey:@"sloveCredit"] stringValue]];
	
	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialViewTapped:)];
	[self.tutorialView addGestureRecognizer:singleFingerTap];

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
	
	[self loadContactsFromCache];
	
	[self observeKeyboard];
	[self initTapToDismiss];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (ApplicationDelegate.needToRefreshContacts) {
		[self reloadContacts];
		
		ApplicationDelegate.needToRefreshContacts = NO;
	}
	
	if (ApplicationDelegate.sloverToSlove) {
		if ([ApplicationDelegate.sloverToSlove count] == 2) {
			[self.navigationController pushViewController:[[SLVContactViewController alloc] initWithContact:[ApplicationDelegate.sloverToSlove firstObject] andPicture:[ApplicationDelegate.sloverToSlove lastObject]] animated:YES];
		} else if ([ApplicationDelegate.sloverToSlove count] == 1) {
			[self.navigationController pushViewController:[[SLVContactViewController alloc] initWithContact:[ApplicationDelegate.sloverToSlove firstObject] andPicture:nil] animated:YES];
		}
		
		ApplicationDelegate.sloverToSlove = nil;
	} else if (ApplicationDelegate.tutorialSloveSent) {
		[ApplicationDelegate disableNavigationElements];
		[self.tutorialView showByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Achievement"
																   action:@"Unlocked"
																	label:@"Tutorial - Daily credit"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Achievement] Unlocked tutorial daily credit"];
	} else if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		[self startTutorial];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
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
		
		SLVSlovedPopupViewController *slovedPopup = [[SLVSlovedPopupViewController alloc] initWithContact:firstSlover andPicture:[ApplicationDelegate.parseConfig objectForKey:PARSE_FIRST_SLOVE_PICTURE]];
		
		[self.navigationController presentViewController:slovedPopup animated:YES completion:nil];
	} else {
		[self performSelector:@selector(startTutorial) withObject:nil afterDelay:5];
	}
}

- (void)didDismissSlovedPopup {
//	if (!IS_IOS7) {
//		[self viewDidAppear:YES];
//	}
}

// TODO: end this function
- (void)loadContactsFromCache {
	NSString *key = [NSString stringWithFormat:@"%@-%@", KEY_CACHED_CONTACTS, [PFUser currentUser].username];
	
	NSArray *cachedContacts = [USER_DEFAULTS objectForKey:key];
	if (!cachedContacts) {
		[self reloadContacts];
	}
}

- (void)reloadContacts {
	if (!self.isAlreadyLoading) {
		SLVLog(@"Reloading contacts...");
		
		[self.searchTextField resignFirstResponder];
		self.searchTextField.text = @"";
		
		self.isAlreadyLoading = YES;
		
		if (![self.refreshControl isRefreshing]) {
			[self.loadingIndicator startAnimating];
		}
		
		self.synchronizedContacts = [[NSArray alloc] init];
		self.addressBookContacts = [[NSArray alloc] init];
		self.fullSynchronizedContacts = [[NSArray alloc] init];
		self.fullAddressBookContacts = [[NSArray alloc] init];
		self.addressBookContacts = [[NSArray alloc] init];
		self.facebookContacts = [[NSArray alloc] init];
		
		self.addressBookContactsReady = NO;
		self.facebookContactsReady = NO;
		
		[self checkAddressBookAccessAuthorization];
		[self checkFacebookFriendsAuthorization];
		
		[self loadSynchronizedContacts];
	}
}

- (void)checkAddressBookAccessAuthorization {
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		
		[self loadAddressBookFromAddressBookRef:self.addressBookRef];
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
		SLVLog(@"%@Address book access not granted", SLV_WARNING);
	} else {
		SLVLog(@"%@Address book access never asked", SLV_WARNING);
		
		if (!([USER_DEFAULTS objectForKey:KEY_ASK_CONTACT_BOOK] && [[USER_DEFAULTS objectForKey:KEY_ASK_CONTACT_BOOK] boolValue]) && !self.popupIsDisplayed) {
			self.popupIsDisplayed = YES;
			
			self.addressBookPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_addressBookAccess", nil) body:NSLocalizedString(@"popup_body_addressBookAccess", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_confirm", nil), nil] andDismissButton:YES];
			
			self.addressBookPopup.delegate = self;
			self.addressBookPopup.priority = kPriorityHigh;
			
			[ApplicationDelegate.queuedPopups addObject:self.addressBookPopup];
			
			[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																	   action:@"Custom access address book"
																		label:@"Displayed"
																		value:@1] build]];
			
			[[Amplitude instance] logEvent:@"[Popup] Custom access address book displayed"];
		}
	}
	
	self.addressBookContactsReady = YES;
}

- (void)checkFacebookFriendsAuthorization {
	if (![FBSDKAccessToken currentAccessToken]) {
		SLVLog(@"%@Not connected through Facebook", SLV_WARNING);
		
		self.facebookContactsReady = YES;
		
		return;
	}
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"me/permissions/user_friends"
								  parameters:@{@"fields": @""}
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			NSArray *data = [result objectForKey:@"data"];
			
			if (!data || [data count] == 0) {
				self.facebookContactsReady = YES;
				
				return;
			}
			
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
						
						
						[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																				   action:@"Custom access facebook friends"
																					label:@"Displayed"
																					value:@1] build]];
						
						[[Amplitude instance] logEvent:@"[Popup] Custom access facebook friends displayed"];
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
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
															   action:@"Setting access address book"
																label:@"Displayed"
																value:@1] build]];
	
	[[Amplitude instance] logEvent:@"[Popup] Setting access address book displayed"];
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
				
				[self reloadContacts];
				
				[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																		   action:@"Apple access address book"
																			label:@"Accepted"
																			value:@1] build]];
				
				[[Amplitude instance] logEvent:@"[Popup] Apple access address book accepted"];
			} else {
				SLVLog(@"%@User didn't grant access to his contact list", SLV_WARNING);
				
				[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																		   action:@"Apple access address book"
																			label:@"Declined"
																			value:@1] build]];
				
				[[Amplitude instance] logEvent:@"[Popup] Apple access address book declined"];
			}
		});
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																   action:@"Apple access address book"
																	label:@"Displayed"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Popup] Apple access address book displayed"];
	}
}

- (void)askFacebookFriends {
	FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
	[loginManager logInWithReadPermissions:[NSArray arrayWithObjects:@"user_friends", nil] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
		if (!error) {
			if ([result.grantedPermissions containsObject:@"user_friends"]) {
				SLVLog(@"User have granted access to his friend list");
				
				[self reloadContacts];
				
				[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																		   action:@"Facebook access facebook friends"
																			label:@"Accepted"
																			value:@1] build]];
				
				[[Amplitude instance] logEvent:@"[Popup] Facebook access facebook friends accepted"];
			} else {
				SLVLog(@"%@User didn't grant access to his friend list", SLV_WARNING);
				
				[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																		   action:@"Facebook access facebook friends"
																			label:@"Declined"
																			value:@1] build]];
				
				[[Amplitude instance] logEvent:@"[Popup] Facebook access facebook friends declined"];
			}
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
															   action:@"Facebook access facebook friends"
																label:@"Displayed"
																value:@1] build]];
	
	[[Amplitude instance] logEvent:@"[Popup] Facebook access facebook friends displayed"];
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
	
	self.addressBookContacts = [addressBookBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
	
	self.fullAddressBookContacts = self.addressBookContacts;
}

- (void)loadFriends {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"5000" forKey:@"limit"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/friends?fields=name,picture.width(720)"
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
						friend.pictureUrl = [NSURL URLWithString:pictureURLString];
					}
					
					[friends addObject:friend];
				}
			}
			
			self.facebookContacts = [NSArray arrayWithArray:friends];
			
			self.facebookContactsReady = YES;
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			
			self.facebookContactsReady = YES;
		}
	}];
}

- (void)loadPuppy {
	SLVAddressBookContact *puppy = [[SLVAddressBookContact alloc] init];
	puppy.fullName = NSLocalizedString(@"stranger_username", nil);
	puppy.username = PUPPY_USERNAME;
	puppy.picture = [UIImage imageNamed:[USER_DEFAULTS objectForKey:KEY_PUPPY_PROFILE_PICTURE_PATH]];
	
	NSMutableArray *synchronizedContactsBuffer = [[NSMutableArray alloc] initWithArray:self.synchronizedContacts];
	
	[synchronizedContactsBuffer insertObject:puppy atIndex:0];
	
	self.synchronizedContacts = [[NSArray alloc] initWithArray:synchronizedContactsBuffer];
}

- (void)loadSynchronizedContacts {
	if (!(self.addressBookContactsReady && self.facebookContactsReady)) {
		// TODO: fix issue that stop the performSelector when called from soloButtonPressed:
		
		[self performSelector:@selector(loadSynchronizedContacts) withObject:nil afterDelay:1];
		
		return;
	}
	
	PFQuery *query = [PFQuery queryWithClassName:OBJECT_USER_DATA];
	[query whereKey:@"user" equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
		if (!error) {
			SLVLog(@"Received data from server: %@", objects);
			
			NSArray *phoneNumbers = [self phoneNumbers];
			NSArray *facebookIds = [self facebookIds];
			
//			NSString *phoneNumbersString;
//			for (NSString *phoneNumber in phoneNumbers) {
//				phoneNumbersString = [phoneNumbersString stringByAppendingString:phoneNumber];
//			}
//			
//			NSString *facebookIdsString;
//			for (NSString *facebookId in facebookIds) {
//				facebookIdsString = [facebookIdsString stringByAppendingString:facebookId];
//			}
			
			
			NSString *phoneNumbersMD5;
			if ([phoneNumbers count] > 0) {
				phoneNumbersMD5 = [[phoneNumbers description] MD5];
			}
			
			NSString *facebookIdsMD5;
			if ([facebookIds count] > 0) {
				facebookIdsMD5 = [[facebookIds description] MD5];
			}
			
			NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
			
			if ([objects count] == 1) {
				PFObject *userData = [objects firstObject];
				NSMutableDictionary *hashKeys = [[NSMutableDictionary alloc] initWithDictionary:[userData objectForKey:@"contactsHash"]];
				
				if (phoneNumbersMD5 && ![[hashKeys objectForKey:@"phone"] isEqualToString:phoneNumbersMD5]) {
					NSDictionary *phoneDictionary = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumbers, @"contacts", phoneNumbersMD5, @"hash", nil];
					[params setObject:phoneDictionary forKey:@"phone"];
				}
				
				if (facebookIdsMD5 && ![[hashKeys objectForKey:@"facebook"] isEqualToString:facebookIdsMD5]) {
					NSDictionary *facebookDictionary = [NSDictionary dictionaryWithObjectsAndKeys:facebookIds, @"contacts", facebookIdsMD5, @"hash", nil];
					[params setObject:facebookDictionary forKey:@"facebook"];
				}
			} else {
				if (phoneNumbersMD5) {
					NSDictionary *phoneDictionary = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumbers, @"contacts", phoneNumbersMD5, @"hash", nil];
					[params setObject:phoneDictionary forKey:@"phone"];
				}
				
				if (facebookIdsMD5) {
					NSDictionary *facebookDictionary = [NSDictionary dictionaryWithObjectsAndKeys:facebookIds, @"contacts", facebookIdsMD5, @"hash", nil];
					[params setObject:facebookDictionary forKey:@"facebook"];
				}
			}
			
			[PFCloud callFunctionInBackground:SYNCHRONIZE_SLOVERS
							   withParameters:params
										block:^(id object, NSError *error){
											if (!error) {
												SLVLog(@"Received data from server: %@", object);
												
												NSArray *slovers = [object objectForKey:@"slovers"];
												
												NSMutableArray *synchronizedContactBuffer = [[NSMutableArray alloc] init];
												
												for (PFUser *user in slovers) {
													NSString *username = [user objectForKey:@"username"];
													
													if (![username isEqualToString:[[PFUser currentUser] objectForKey:@"username"]]) {
														SLVContact *slover = [[SLVContact alloc] init];
														
														slover.username = username;
														
														slover.phoneNumber = [user objectForKey:@"phoneNumber"];
														
														NSString *pictureUrlString = [user objectForKey:@"pictureUrl"];
														if (pictureUrlString && ![pictureUrlString isEqualToString:@""]) {
															slover.pictureUrl = [NSURL URLWithString:pictureUrlString];
															
															SDWebImageManager *manager = [SDWebImageManager sharedManager];
															[manager downloadImageWithURL:slover.pictureUrl
																				  options:0
																				 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
																					 if (expectedSize > 0) {
																						 float prct = 100.0 * receivedSize / expectedSize;
																						 SLVLog(@"Downloading '%@' profile picture: %.02f%%", slover.username, prct);
																					 }
																				 }
																				completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
																					if (image) {
																						SLVLog(@"Download of '%@' profile picture complete!", slover.username);
																					}
																				}];
														}
														
														NSString *levelKey = [NSString stringWithFormat:@"%@-%@", KEY_CONTACT_LEVELUP, username];
														NSNumber *currentLevel = [USER_DEFAULTS objectForKey:levelKey];
														
														if (currentLevel) {
															slover.currentLevel = [ApplicationDelegate.levels objectAtIndex:[currentLevel intValue]];
														}
														
														for (SLVAddressBookContact *addressBookContact in self.addressBookContacts) {
															for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
																if ([[phoneNumberDic objectForKey:@"formatedPhoneNumber"] isEqualToString:slover.phoneNumber]) {
																	SLVLog(@"Synchonizing address book contact '%@' with '%@'", addressBookContact.fullName, slover.username);
																	
																	slover.fullName = addressBookContact.fullName;
																	
																	self.addressBookContacts = [self removeContact:addressBookContact FromContacts:self.addressBookContacts];
																}
															}
														}
														
														if (!slover.fullName || [slover.fullName isEqualToString:@""]) {
															for (SLVFacebookFriend *facebookContact in self.facebookContacts) {
																if ([facebookContact.facebookId isEqualToString:[user objectForKey:@"facebookId"]]) {
																	SLVLog(@"Synchonizing facebook contact '%@' with '%@'", facebookContact.fullName, slover.username);
																	
																	slover.fullName = facebookContact.fullName;
																	
																	self.facebookContacts = [self removeContact:facebookContact FromContacts:self.facebookContacts];
																}
															}
														}
														
														if (!slover.fullName || [slover.fullName isEqualToString:@""]) {
															slover.fullName = @"";
															
															NSString *firstName = [user objectForKey:@"firstName"];
															NSString *lastName = [user objectForKey:@"lastName"];
															
															if (firstName) {
																slover.fullName = firstName;
															}
															
															if (lastName) {
																if (![slover.fullName isEqualToString:@""]) {
																	slover.fullName = [slover.fullName stringByAppendingString:@" "];
																}
																
																slover.fullName = [slover.fullName stringByAppendingString:lastName];
															}
														}
														
														[synchronizedContactBuffer addObject:slover];
													}
												}
												
												self.fullAddressBookContacts = self.addressBookContacts;
												
												self.synchronizedContacts = [synchronizedContactBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
													return [a.fullName caseInsensitiveCompare:b.fullName];
												}];
												
												if (PUPPY_IS_ENABLED) {
													[self loadPuppy];
												}
												
												self.fullSynchronizedContacts = self.synchronizedContacts;
											} else {
												SLVLog(@"%@%@", SLV_ERROR, error.description);
												[ParseErrorHandlingController handleParseError:error];
											}
											
											[self loadSynchronizedContactsIsEnding];
										}];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			
			SLVInteractionPopupViewController *disconnectPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_pull_again", nil) buttonsTitle:nil andDismissButton:YES];
			[ApplicationDelegate.currentNavigationController presentViewController:disconnectPopup animated:YES completion:nil];
			
			[self loadSynchronizedContactsIsEnding];
		}
	}];
}

- (void)loadSynchronizedContactsIsEnding {
	if ([self.loadingIndicator isAnimating]) {
		[self.loadingIndicator stopAnimating];
	}
	
	[self.contactTableView reloadData];
	[self.contactTableView showByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
	
	if ([self.refreshControl isRefreshing]) {
		[self.refreshControl endRefreshing];
	}
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Contact"
															   action:@"Load"
																label:@"Address Book"
																value:[NSNumber numberWithInteger:[self.fullAddressBookContacts count]]] build]];
	
	NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
	[eventProperties setValue:[NSNumber numberWithInteger:[self.fullAddressBookContacts count]] forKey:@"Value"];
	[[Amplitude instance] logEvent:@"[Contact] Load address book" withEventProperties:eventProperties];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Contact"
															   action:@"Load"
																label:@"Facebook"
																value:[NSNumber numberWithInteger:[self.facebookContacts count]]] build]];
	
	eventProperties = [NSMutableDictionary dictionary];
	[eventProperties setValue:[NSNumber numberWithInteger:[self.facebookContacts count]] forKey:@"Value"];
	[[Amplitude instance] logEvent:@"[Contact] Load facebook" withEventProperties:eventProperties];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Contact"
															   action:@"Load"
																label:@"Synchronized"
																value:[NSNumber numberWithInteger:[self.fullSynchronizedContacts count]]] build]];
	
	eventProperties = [NSMutableDictionary dictionary];
	[eventProperties setValue:[NSNumber numberWithInteger:[self.fullSynchronizedContacts count]] forKey:@"Value"];
	[[Amplitude instance] logEvent:@"[Contact] Load synchronized" withEventProperties:eventProperties];
	
	self.isAlreadyLoading = NO;
}

- (NSArray *)phoneNumbers {
	NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
	
	for (SLVAddressBookContact *addressBookContact in self.addressBookContacts) {
		for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
			[phoneNumbers addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
		}
	}
	
	return [[NSArray alloc] initWithArray:[phoneNumbers sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

- (NSArray *)facebookIds {
	NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
	
	for (SLVFacebookFriend *friend in self.facebookContacts) {
		if (friend.facebookId) {
			[facebookIds addObject:friend.facebookId];
		}
	}
	
	return [[NSArray alloc] initWithArray:[facebookIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

- (NSArray *)removeContact:(SLVContact *)contact FromContacts:(NSArray *)contacts {
	NSMutableArray *contactsBuffer = [NSMutableArray arrayWithArray:contacts];
	[contactsBuffer removeObject:contact];
	return [NSArray arrayWithArray:contactsBuffer];
}

- (void)showAddSloverView:(UIButton *)button {
	SLVAddSloverViewController *addSloverViewController = [[SLVAddSloverViewController alloc] initWithHomeViewController:self];
	
	[self.navigationController pushViewController:addSloverViewController animated:YES];
}

- (void)inviteAction:(UIButton *)button {
	SLVLog(@"User is trying to share Slove!");
	
	NSString *shareText = NSLocalizedString(@"label_share_with_friends", nil);
	shareText = [shareText stringByReplacingOccurrencesOfString:@"[app_url]" withString:[ApplicationDelegate.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL]];
	
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
	SLVAddressBookContact *addressBookContact = [self.addressBookContacts objectAtIndex:button.tag];
	
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
	
	NSString *message = NSLocalizedString(@"label_share_with_friends", nil);
	message = [message stringByReplacingOccurrencesOfString:@"[app_url]" withString:[ApplicationDelegate.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL]];
	
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

- (void)observeKeyboard {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	if (!self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
		NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		CGRect keyboardFrame = [kbFrame CGRectValue];
		
		CGFloat height = keyboardFrame.size.height;
		
		self.keyboardLayoutConstraint.constant += height;
		
		[UIView animateWithDuration:animationDuration animations:^{
			[self.view layoutIfNeeded];
		}];
		
		self.keyboardIsVisible = YES;
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		
		self.keyboardLayoutConstraint.constant = 8;
		
		[UIView animateWithDuration:animationDuration animations:^{
			[self.view layoutIfNeeded];
		}];
		
		self.keyboardIsVisible = NO;
	}
}

- (void)initTapToDismiss {
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
										   initWithTarget:self
										   action:@selector(hideKeyboard)];
	
	tapGesture.delegate = self;
	
	[self.view addGestureRecognizer:tapGesture];
}

- (void)hideKeyboard {
	for (UITextField *textField in self.searchView.subviews) {
		[textField resignFirstResponder];
	}
}

- (void)tutorialViewTapped:(id)sender {
	[self.tutorialView hideByFadingWithDuration:ANIMATION_DURATION AndCompletion:^{
		ApplicationDelegate.tutorialSloveSent = NO;
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:NO] forKey:KEY_FIRST_TIME_TUTORIAL];
		[ApplicationDelegate enableNavigationElements];
	}];
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
	return TABLE_CELL_HEIGHT;
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
		if (section == ([tableView numberOfSections] - 1)) {
			if ((([self.synchronizedContacts count] + 1) * TABLE_CELL_HEIGHT) >= tableView.frame.size.height) {
				return [self.synchronizedContacts count] + 1;
			} else {
				return [self.synchronizedContacts count];
			}
		} else {
			return [self.synchronizedContacts count];
		}
	}
	
	if (section == ([tableView numberOfSections] - 1)) {
		if ((([self.addressBookContacts count] + 1) * TABLE_CELL_HEIGHT) >= tableView.frame.size.height) {
			return [self.addressBookContacts count] + 1;
		} else {
			return [self.addressBookContacts count];
		}
	} else {
		return [self.addressBookContacts count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL isSynchronized = NO;
	
	if (indexPath.section == 0 && [self.synchronizedContacts count] > 0) {
		isSynchronized = YES;
	}
	
	NSString *identifier;
	if (isSynchronized) {
		identifier = @"SynchronizedContactCell";
	} else {
		identifier = @"UnsynchronizedContactCell";
	}
	
	SLVContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"SLVContactTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	}
	
	[SLVViewController setStyle:cell];
	
	if ((isSynchronized && (indexPath.row == [self.synchronizedContacts count])) || (!isSynchronized && (indexPath.row == [self.addressBookContacts count]))) {
		cell.hidden = YES;
			
		return cell;
	} else {
		cell.hidden = NO;
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.subtitleImageView.image = [UIImage imageNamed:@"Assets/Image/coeur_rouge"];
	[cell.selectionButton setBackgroundImage:[UIImage imageNamed:@"Assets/Image/fleche_go_profil"] forState:UIControlStateNormal];
	cell.selectionButton.userInteractionEnabled = NO;
	cell.subtitleLabel.textColor = BLUE;
	
	SLVContact *contact;
	
	if (isSynchronized) {
		contact = [self.synchronizedContacts objectAtIndex:indexPath.row];
	} else if ([self.addressBookContacts count] > 0) {
		contact = [self.addressBookContacts objectAtIndex:indexPath.row];
		cell.subtitleImageView.image = nil;
		cell.subtitleLabel.textColor = nil;
		[cell.selectionButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_ajout_contact"] forState:UIControlStateNormal];
		cell.selectionButton.userInteractionEnabled = YES;
		cell.selectionButton.tag = indexPath.row;
		[cell.selectionButton addTarget:self action:@selector(inviteBySMS:) forControlEvents:UIControlEventTouchUpInside];
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
	
	if (contact.pictureUrl) {
		[cell.pictureImageView setImageWithURL:contact.pictureUrl placeholderImage:[UIImage imageNamed:@"Assets/Avatar/avatar_user"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	} else if ([contact isKindOfClass:[SLVAddressBookContact class]] && ((SLVAddressBookContact *)contact).picture) {
		cell.pictureImageView.image = ((SLVAddressBookContact *)contact).picture;
	} else {
		cell.pictureImageView.image = [UIImage imageNamed:@"Assets/Avatar/avatar_user"];
	}
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.clipsToBounds = YES;
	
	cell.layerImageView.image = [UIImage imageNamed:@"Assets/Layer/masque_profil_repertoire"];
	
	cell.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	
	cell.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT size:DEFAULT_FONT_SIZE_SMALL];
	
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
	
	[self.navigationController pushViewController:[[SLVContactViewController alloc] initWithContact:contact andPicture:nil] animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, [self tableView:tableView heightForHeaderInSection:section])];
	headerView.backgroundColor = VERY_LIGHT_GRAY;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 1, headerView.frame.size.width - 8 * 2, headerView.frame.size.height - 1 * 2)];
	label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_LARGE];
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
		
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_CONTACT_BOOK];
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																   action:@"Custom access address book"
																	label:@"Accepted"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Popup] Custom access address book accepted"];
	} else if (popup == self.facebookPopup) {
		[self askFacebookFriends];
		
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_FACEBOOK_FRIENDS];
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																   action:@"Custom access facebook friends"
																	label:@"Accepted"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Popup] Custom access facebook friends accepted"];
	}
}

- (void)dismissButtonPressed:(SLVInteractionPopupViewController *)popup {
	self.popupIsDisplayed = NO;
	
	if (popup == self.addressBookPopup) {
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_CONTACT_BOOK];
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																   action:@"Custom access address book"
																	label:@"Dismissed"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Popup] Custom access address book dismissed"];
	} else if (popup == self.facebookPopup) {
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_ASK_FACEBOOK_FRIENDS];
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
																   action:@"Custom access facebook friends"
																	label:@"Dismissed"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Popup] Custom access facebook friends dismissed"];
	}
}


#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if (result == MessageComposeResultSent) {
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Contact"
																   action:@"SMS invite"
																	label:@"Sent"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Contact] SMS invite sent"];
	} else if (result == MessageComposeResultCancelled) {
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Contact"
																   action:@"SMS invite"
																	label:@"Cancelled"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Contact] SMS invite cancelled"];
	}
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(UITextField *)textField {
	if (textField == self.searchTextField) {
		NSString *text = [textField.text stringByTrimmingCharactersInSet:
		[NSCharacterSet whitespaceCharacterSet]];
		
		if(text.length == 0) {
			self.addressBookContacts = self.fullAddressBookContacts;
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
			
			for (SLVAddressBookContact *contact in self.fullAddressBookContacts) {
				NSRange fullNameRange = [contact.fullName rangeOfString:text options:NSCaseInsensitiveSearch];
				if(fullNameRange.location != NSNotFound) {
					[filteredContacts addObject:contact];
				}
			}
			
			self.addressBookContacts = filteredContacts;
		}
		
		[self.contactTableView reloadData];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	if ([touch.view isDescendantOfView:self.contactTableView]) {
		// Don't let selections of auto-complete entries fire the gesture recognizer
		return NO;
	}
	
	return YES;
}

@end
