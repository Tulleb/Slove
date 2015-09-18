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

@interface SLVHomeViewController ()

@end

@implementation SLVHomeViewController

- (void)viewDidLoad {
	self.appName = @"home";
	
	[super viewDidLoad];
	
	[self.favoriteButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.favoriteButton setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
	[self.favoriteButton setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
	
	[self.contactButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.contactButton setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
	[self.contactButton setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
	
	[self.facebookButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.facebookButton setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
	[self.facebookButton setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
	
	self.filterButtons = [[NSArray alloc] initWithObjects:self.favoriteButton, self.contactButton, self.facebookButton, nil];
	
	self.filterBackgroundImageView.image = [UIImage imageNamed:@"Assets/Image/menunuage_repertoire_contacts"];
	
	// To call viewWillAppear after return from Sloved popup
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didDismissSlovedPopup)
												 name:NOTIFICATION_SLOVEDPOPUP_DISMISSED
											   object:nil];
	
	self.selectedFilterIndex = 0;
	self.favoriteButton.selected = YES;
	[self filterChanged:self.favoriteButton];
}

- (void)viewDidAppear:(BOOL)animated {
	if (ApplicationDelegate.sloverToSlove) {
		[super viewDidAppear:YES];
		
		[self.navigationController pushViewController:[[SLVProfileViewController alloc] initWithContact:ApplicationDelegate.sloverToSlove] animated:YES];
		
		ApplicationDelegate.sloverToSlove = nil;
	} else if ([[[NSUserDefaults standardUserDefaults] objectForKey:KEY_FIRSTTIME_TUTORIAL] boolValue]) {
		[super viewDidAppear:animated];
		
		[self startTutorial];
	} else {
		[super viewDidAppear:animated];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)filterChanged:(id)sender {
	if ([sender isKindOfClass:[UIButton class]]) {
		UIButton *filterButton = (UIButton *)sender;
		
		self.selectedFilterIndex = (int)filterButton.tag;
		
		for (UIButton *button in self.filterButtons) {
			button.selected = button.tag == self.selectedFilterIndex;
		}
		
		self.contactTableView.hidden = NO;
		[self.loadingIndicator startAnimating];
		
		switch (self.selectedFilterIndex) {
			case kFavoriteFilter: {
				self.filterBackgroundImageView.image = [UIImage imageNamed:@"Assets/Image/menunuage_repertoire_favoris"];
				
				[self.loadingIndicator stopAnimating];
				[self.contactTableView reloadData];
				break;
			}
				
			case kAddressBookFilter: {
				self.filterBackgroundImageView.image = [UIImage imageNamed:@"Assets/Image/menunuage_repertoire_contacts"];
				
				if ([self checkAddressBookAccessAuthorization]) {
					[self contactsAccessGranted];
				} else {
					[self.loadingIndicator stopAnimating];
					
					self.addressBookPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_addressBookAccess", nil) body:NSLocalizedString(@"popup_body_addressBookAccess", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_confirm", nil), nil] andDismissButton:YES];
					
					self.addressBookPopup.delegate = self;
					
					[self presentViewController:self.addressBookPopup animated:YES completion:nil];
					
					self.contactTableView.hidden = YES;
				}
				break;
			}
				
			case kFacebookFilter: {
				self.filterBackgroundImageView.image = [UIImage imageNamed:@"Assets/Image/menunuage_repertoire_facebook"];
				
				[self checkFacebookFriendsAuthorization];
				
				break;
			}
				
			default:
				break;
		}
	}
}

- (void)startTutorial {
	if ([ApplicationDelegate.parseConfig objectForKey:PARSE_FIRSTSLOVE_PICTURE]) {
		SLVContact *firstSlover = [[SLVContact alloc] init];
		
		firstSlover.username = [ApplicationDelegate.parseConfig objectForKey:PARSE_FIRSTSLOVE_USERNAME];
		firstSlover.picture = [ApplicationDelegate.parseConfig objectForKey:PARSE_FIRSTSLOVE_PICTURE];
		
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

- (BOOL)checkAddressBookAccessAuthorization {
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		return YES;
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
		[self showSettingManipulation];
	}
	
	return NO;
}

- (void)checkFacebookFriendsAuthorization {
	if (![FBSDKAccessToken currentAccessToken]) {
		SLVLog(@"%@Not connected through Facebook", SLV_WARNING);
		[self.loadingIndicator stopAnimating];
		
		self.errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_notConnectedWithFacebook", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_ok", nil), nil] andDismissButton:NO];
		
		self.errorPopup.delegate = self;
		
		[self presentViewController:self.errorPopup animated:YES completion:nil];
		
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
					[self friendsAccessGranted];
				} else {
					SLVLog(@"%@Facebook friends access not granted", SLV_WARNING);
					[self.loadingIndicator stopAnimating];
					
					self.facebookPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_facebookAccess", nil) body:NSLocalizedString(@"popup_body_facebookAccess", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_confirm", nil), nil] andDismissButton:YES];
					
					self.facebookPopup.delegate = self;
					
					[self presentViewController:self.facebookPopup animated:YES completion:nil];
					
					self.contactTableView.hidden = YES;
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

- (void)contactsAccessGranted {
	if (!self.unsynchronizedAddressBookContacts) {
		self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		[self loadContacts];
	} else {
		[self.loadingIndicator stopAnimating];
		[self.contactTableView reloadData];
	}
}

- (void)friendsAccessGranted {
	if (!self.facebookFriends) {
		[self loadFriends];
	} else {
		[self.loadingIndicator stopAnimating];
		[self.contactTableView reloadData];
	}
}

- (void)loadContacts {
	[self loadAddressBookFromAddressBookRef:self.addressBookRef];
	[self synchronizeContacts];
}

- (void)loadFriends {
	[self loadFriendsFromFacebook];
}

- (void)showSettingManipulation {
	SLVLog(@"%@User denied the access to his address book", SLV_ERROR);
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
					cachedContact.picture = [UIImage imageNamed:@"Assets/Avatar/default_avatar"];
				}
				
				[addressBookBuffer addObject:cachedContact];
			}
		}
	}
	
	self.unsynchronizedAddressBookContacts = [addressBookBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
}

- (void)loadFriendsFromFacebook {
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
			NSMutableArray *friends = [self.facebookFriends mutableCopy];
			
			if (!friends) {
				friends = [[NSMutableArray alloc] init];
			}
			
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
							friend.picture = [UIImage imageNamed:@"Assets/Avatar/default_avatar"];
							friend.pictureDownloaded = YES;
						}
					} else {
						friend.picture = previousPicture;
						friend.pictureDownloaded = YES;
					}
					
					[friends addObject:friend];
				}
			}
			
			self.facebookFriends = [friends sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
				return [a.fullName caseInsensitiveCompare:b.fullName];
			}];
			
			[self synchronizeFriends];
			[self downloadPictures];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}

- (void)downloadPictures {
	BOOL downloadNeeded = NO;
	
	for (SLVFacebookFriend *friend in self.facebookFriends) {
		if (!friend.pictureDownloaded) {
			downloadNeeded = YES;
			break;
		}
	}
	
	if (!downloadNeeded) {
		return;
	}
	
	self.loadingLabel.hidden = NO;
	int previousPercentage = -1;
	
	for (SLVFacebookFriend *friend in self.facebookFriends) {
		if (!friend.pictureDownloaded) {
			int percentage = (int)((([self.facebookFriends indexOfObject:friend] + 1) / (float)([self.facebookFriends count])) * 100);
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
	
	self.loadingLabel.hidden = YES;
}

- (void)synchronizeContacts {
	if (!self.synchronizedAddressBookContacts) {
		NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
		
		for (SLVAddressBookContact *addressBookContact in self.unsynchronizedAddressBookContacts) {
			for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
				[phoneNumbers addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
			}
		}
		
		[PFCloud callFunctionInBackground:SYNCHRONIZE_CONTACTS_FUNCTION
						   withParameters:@{@"phoneNumbers" : phoneNumbers}
									block:^(id object, NSError *error){
										if (!error) {
											self.synchronizedAddressBookContacts = [[NSArray alloc] init];
											
											NSDictionary *datas = object;
											NSArray *registeredContacts = [datas objectForKey:@"registeredContacts"];
											
											if (registeredContacts && [registeredContacts count] > 0) {
												for (NSDictionary *registeredContact in registeredContacts) {
													NSString *username = [registeredContact objectForKey:@"username"];
													
													if (![username isEqualToString:[PFUser currentUser].username]) {
														for (SLVAddressBookContact *addressBookContact in self.unsynchronizedAddressBookContacts) {
															for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
																if ([[phoneNumberDic objectForKey:@"formatedPhoneNumber"] isEqualToString:[registeredContact objectForKey:@"phoneNumber"]]) {
																	addressBookContact.username = username;
																	
																	NSString *pictureUrl = [registeredContact objectForKey:@"pictureUrl"];
																	if (pictureUrl && ![pictureUrl isEqualToString:@""]) {
																		addressBookContact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
																	}
																	
																	SLVLog(@"Contact '%@' synchronized with username '%@'", addressBookContact.fullName, addressBookContact.username);
																	
																	[self moveContactToSynchronizedArray:addressBookContact];
																}
															}
														}
													}
												}
												
												NSMutableArray *synchronizedAddressBookContactsBuffer = [self.synchronizedAddressBookContacts mutableCopy];
												self.synchronizedAddressBookContacts = [synchronizedAddressBookContactsBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
													return [a.fullName caseInsensitiveCompare:b.fullName];
												}];
											}
										} else {
											SLVLog(@"%@%@", SLV_ERROR, error.description);
											[ParseErrorHandlingController handleParseError:error];
										}
										
										[self.loadingIndicator stopAnimating];
										[self.contactTableView reloadData];
									}];
	}
}

- (void)synchronizeFriends {
	NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
	
	for (SLVFacebookFriend *facebookFriend in self.facebookFriends) {
		if (facebookFriend.facebookId) {
			[facebookIds addObject:facebookFriend.facebookId];
		}
	}
	
	[PFCloud callFunctionInBackground:SYNCHRONIZE_FRIENDS_FUNCTION
					   withParameters:@{@"facebookIds" : facebookIds}
								block:^(id object, NSError *error){
									if (!error) {
										NSDictionary *datas = object;
										NSArray *registeredContacts = [datas objectForKey:@"registeredFriends"];
										
										if (registeredContacts && [registeredContacts count] > 0) {
											for (NSDictionary *registeredContact in registeredContacts) {
												NSString *username = [registeredContact objectForKey:@"username"];
												
												if (![username isEqualToString:[PFUser currentUser].username]) {
													for (SLVFacebookFriend *facebookContact in self.facebookFriends) {
														if ([facebookContact.facebookId isEqualToString:[registeredContact objectForKey:@"facebookId"]]) {
															facebookContact.username = username;
															
															NSString *pictureURLString = [registeredContact objectForKey:@"pictureUrl"];
															
															if (pictureURLString && ![pictureURLString isEqualToString:@""]) {
																if (![pictureURLString isEqualToString:facebookContact.pictureURLString]) {
																	facebookContact.pictureURLString = pictureURLString;
																	facebookContact.pictureDownloaded = NO;
																} else {
																	UIImage *previousPicture = [SLVTools loadImageWithName:facebookContact.fullName];
																	if (!previousPicture) {
																		facebookContact.pictureDownloaded = NO;
																	} else {
																		facebookContact.picture = previousPicture;
																		facebookContact.pictureDownloaded = YES;
																	}
																}
															}
															
															SLVLog(@"Contact '%@' synchronized with username '%@'", facebookContact.fullName, facebookContact.username);
														}
													}
												}
											}
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
									
									[self.loadingIndicator stopAnimating];
									[self.contactTableView reloadData];
								}];
}

- (void)moveContactToSynchronizedArray:(SLVContact *)contact {
	if ([contact isKindOfClass:[SLVAddressBookContact class]]) {
		NSMutableArray *unsynchronizedAddressBookContactsBuffer = [self.unsynchronizedAddressBookContacts mutableCopy];
		[unsynchronizedAddressBookContactsBuffer removeObject:contact];
		self.unsynchronizedAddressBookContacts = unsynchronizedAddressBookContactsBuffer;
		
		NSMutableArray *synchronizedAddressBookContactsBuffer = [self.synchronizedAddressBookContacts mutableCopy];
		[synchronizedAddressBookContactsBuffer addObject:contact];
		self.synchronizedAddressBookContacts = synchronizedAddressBookContactsBuffer;
	}
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (self.selectedFilterIndex) {
		case kFavoriteFilter:
			return 1;
			
		case kAddressBookFilter:
			if ([self.synchronizedAddressBookContacts count] > 0) {
				return 2;
			} else {
				return 1;
			}
			
		case kFacebookFilter:
			return 1;
			
		default:
			return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (self.selectedFilterIndex) {
		case kAddressBookFilter:
			if ([self.synchronizedAddressBookContacts count] > 0) {
				if (section == 0) {
					return NSLocalizedString(@"section_slovers", nil);
				} else {
					return NSLocalizedString(@"section_invite_on_slove", nil);
				}
			} else {
				return nil;
			}
			
		default:
			return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	switch (self.selectedFilterIndex) {
		case kAddressBookFilter:
			if ([self.synchronizedAddressBookContacts count] > 0) {
				return 1 * 2 + 30;
			} else {
				return 0;
			}
			
		default:
			return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (self.selectedFilterIndex) {
		case kFavoriteFilter:
			return [self.favoriteContacts count];
			
		case kAddressBookFilter:
			if (([self.synchronizedAddressBookContacts count] > 0) && (section == 0)) {
				return [self.synchronizedAddressBookContacts count];
			}
			return [self.unsynchronizedAddressBookContacts count];
			
		case kFacebookFilter:
			return [self.facebookFriends count];
			
		default:
			return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"AddressBookContactCell";
	SLVContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"SLVContactTableViewCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
		cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	SLVContact *contact;
	BOOL isSynchronized = NO;
	
	switch (self.selectedFilterIndex) {
		case kFavoriteFilter:
			contact = [self.favoriteContacts objectAtIndex:indexPath.row];
			break;
			
		case kAddressBookFilter:
			if (indexPath.section == 0 && [self.synchronizedAddressBookContacts count] > 0) {
				contact = [self.synchronizedAddressBookContacts objectAtIndex:indexPath.row];
				isSynchronized = YES;
			} else {
				contact = [self.unsynchronizedAddressBookContacts objectAtIndex:indexPath.row];
			}
			break;
			
		case kFacebookFilter:
			contact = [self.facebookFriends objectAtIndex:indexPath.row];
			isSynchronized = YES;
			break;
			
		default:
			contact = nil;
			break;
	}
	
	if (!contact) {
		return cell;
	}
	
	if (isSynchronized) {
		cell.titleLabel.text = contact.username;
		cell.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
		cell.subtitleLabel.text = contact.fullName;
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
	
	cell.layerImageView.image = [UIImage imageNamed:@"masque_profil_repertoire"];
	
	[SLVViewController setStyle:cell];
	
	cell.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_LARGE];
	cell.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT size:DEFAULT_FONT_SIZE];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SLVContact *contact;
	
	switch (self.selectedFilterIndex) {
		case kFavoriteFilter:
			contact = [self.favoriteContacts objectAtIndex:indexPath.row];
			break;
			
		case kAddressBookFilter:
			if (indexPath.section == 0 && [self.synchronizedAddressBookContacts count] > 0) {
				contact = [self.synchronizedAddressBookContacts objectAtIndex:indexPath.row];
			} else {
				contact = [self.unsynchronizedAddressBookContacts objectAtIndex:indexPath.row];
			}
			break;
			
		case kFacebookFilter:
			contact = [self.facebookFriends objectAtIndex:indexPath.row];
			break;
			
		default:
			break;
	}
	
	SLVLog(@"Selected %@", [contact description]);
	
	[self.navigationController pushViewController:[[SLVProfileViewController alloc] initWithContact:contact] animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, [self tableView:tableView heightForHeaderInSection:section])];
	headerView.backgroundColor = SUB_COLOR;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 1, headerView.frame.size.width - 8 * 2, headerView.frame.size.height - 1 * 2)];
	label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	
	[headerView addSubview:label];
	
	return headerView;
}


#pragma mark - SLVInteractionPopupDelegate

- (void)soloButtonPressed:(SLVInteractionPopupViewController *)popup {
	if (popup == self.addressBookPopup) {
		self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		
		if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
			SLVLog(@"Asking address book access to the user");
			ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
				if (granted) {
					SLVLog(@"User have granted access to his contact list");
					[self contactsAccessGranted];
				} else {
					SLVLog(@"%@User didn't grant access to his contact list", SLV_WARNING);
					[self showSettingManipulation];
				}
			});
		}
	} else if (popup == self.facebookPopup) {
		FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
		[loginManager logInWithReadPermissions:[NSArray arrayWithObjects:@"user_friends", nil] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
			if (!error) {
				if ([result.grantedPermissions containsObject:@"user_friends"]) {
					SLVLog(@"User have granted access to his friend list");
					[self filterChanged:self.facebookButton];
				} else {
					SLVLog(@"%@User didn't grant access to his friend list", SLV_WARNING);
				}
			} else {
				SLVLog(@"%@%@", SLV_ERROR, error.description);
				[ParseErrorHandlingController handleParseError:error];
			}
		}];
	}
}

@end
