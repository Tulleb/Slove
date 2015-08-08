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

@interface SLVHomeViewController ()

@end

@implementation SLVHomeViewController

- (void)viewDidLoad {
	self.appName = @"slove";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self filterChanged:self.filterSegmentedControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)accessContactAction:(id)sender {
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
}

- (IBAction)accessFriendsAction:(id)sender {
	FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
	[loginManager logInWithReadPermissions:[NSArray arrayWithObjects:@"user_friends", nil] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
		if (!error) {
			if ([result.grantedPermissions containsObject:@"user_friends"]) {
				SLVLog(@"User have granted access to his friend list");
				[self friendsAccessGranted];
			} else {
				SLVLog(@"%@User didn't grant access to his friend list", SLV_WARNING);
			}
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

- (IBAction)filterChanged:(id)sender {
	self.contactTableView.hidden = NO;
	
	if (sender == self.filterSegmentedControl) {
		switch (self.filterSegmentedControl.selectedSegmentIndex) {
			case kFavoriteFilter:
				self.accessContactsButton.hidden = YES;
				self.accessFriendsButton.hidden = YES;
				
				break;
				
			case kAddressBookFilter:
				self.accessFriendsButton.hidden = YES;
				
				if ([self checkAddressBookAccessAuthorization]) {
					[self contactsAccessGranted];
				} else {
					self.accessContactsButton.hidden = NO;
					self.contactTableView.hidden = YES;
				}
				break;
			
			case kFacebookFilter:
				self.accessContactsButton.hidden = YES;
				
				if ([self checkFacebookFriendsAuthorization]) {
					[self friendsAccessGranted];
				} else {
					self.accessFriendsButton.hidden = NO;
					self.contactTableView.hidden = YES;
				}
				break;
				
			default:
				break;
		}
		
		[self.contactTableView reloadData];
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

- (BOOL)checkFacebookFriendsAuthorization {
	return ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]);
}

- (void)contactsAccessGranted {
	self.accessContactsButton.hidden = YES;
	
	if (!self.unsynchronizedAddressBookContacts) {
		self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
		[self loadContacts];
	}
}

- (void)friendsAccessGranted {
	self.accessFriendsButton.hidden = YES;
	[self loadFriends];
}

- (void)loadContacts {
	[self loadAddressBookFromAddressBookRef:self.addressBookRef];
	[self synchronizeContacts];
}

- (void)loadFriends {
	[self loadFriendsFromFacebook];
	[self synchronizeContacts];
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
		if (lastNameString && ![fullName isEqualToString:@""]) {
			fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" %@", lastNameString]];
		}
		
		if (![fullName isEqualToString:@""]) {
			if (organizationString && ![organizationString isEqualToString:@""]	) {
				fullName = [fullName stringByAppendingString:[NSString stringWithFormat:@" (%@)", organizationString]];
			}
			
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
				cachedContact.picture = image;
				
				[addressBookBuffer addObject:cachedContact];
			}
		}
	}
	
	self.unsynchronizedAddressBookContacts = [addressBookBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
}

- (void)loadFriendsFromFacebook {
	[self loadTaggableFriends];
	[self loadSloveFriends];
}

- (void)loadTaggableFriends {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"5000" forKey:@"limit"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/taggable_friends?fields=name,picture.width(320)"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			NSMutableArray *friends = [self.unsynchronizedFacebookContacts mutableCopy];
			
			if (!friends) {
				friends = [[NSMutableArray alloc] init];
			}
			
			NSArray *data = [result objectForKey:@"data"];
			
			for (NSDictionary *friendDic in data) {
				NSString *taggableId = [friendDic objectForKey:@"id"];
				NSString *name = [friendDic objectForKey:@"name"];
				NSString *pictureURLString;
				
				NSDictionary *pictureDic = [friendDic objectForKey:@"picture"];
				if (pictureDic) {
					NSDictionary *pictureData = [pictureDic objectForKey:@"data"];
					if (pictureData) {
						pictureURLString = [pictureData objectForKey:@"url"];
					}
				}
				
				if (taggableId && name) {
					SLVFacebookFriend *friend = [[SLVFacebookFriend alloc] init];
					friend.taggableId = taggableId;
					friend.fullName = name;
					
					for (SLVFacebookFriend *recordedFriend in friends) {
						if ([friend.fullName isEqualToString:recordedFriend.fullName]) {
							friend = recordedFriend;
							[friends removeObject:friend];
							
							break;
						}
					}
					
					UIImage *previousPicture = [SLVTools loadImageWithName:friend.fullName];
					if (!previousPicture) {
						if (pictureURLString) {
							if (![pictureURLString isEqualToString:friend.pictureURLString]) {
								friend.pictureURLString = pictureURLString;
								friend.pictureDownloaded = NO;
							}
						}
					} else {
						friend.picture = previousPicture;
						friend.pictureDownloaded = YES;
					}
					
					[friends addObject:friend];
				}
			}
			
			self.unsynchronizedFacebookContacts = [friends sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
				return [a.fullName caseInsensitiveCompare:b.fullName];
			}];
			
			[self downloadPictures];
			[self.contactTableView reloadData];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}

- (void)downloadPictures {
	BOOL downloadNeeded = NO;
	
	for (SLVFacebookFriend *friend in self.unsynchronizedFacebookContacts) {
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
	
	for (SLVFacebookFriend *friend in self.unsynchronizedFacebookContacts) {
		if (!friend.pictureDownloaded) {
			int percentage = (int)((([self.unsynchronizedFacebookContacts indexOfObject:friend] + 1) / (float)([self.unsynchronizedFacebookContacts count])) * 100);
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

- (void)loadSloveFriends {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	
	[params setObject:@"5000" forKey:@"limit"];
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/friends?fields=name"
								  parameters:params
								  HTTPMethod:@"GET"];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		if (result) {
			NSArray *data = [result objectForKey:@"data"];
			
			for (NSDictionary *friendDic in data) {
				NSString *facebookId = [friendDic objectForKey:@"id"];
				NSString *name = [friendDic objectForKey:@"name"];;
				if (facebookId && name) {
					for (SLVFacebookFriend *friend in self.unsynchronizedFacebookContacts) {
						if ([friend.fullName isEqualToString:name]) {
							friend.facebookId = facebookId;
						}
					}
				}
			}
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}

- (void)synchronizeContacts {
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
											
											[self.contactTableView reloadData];
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
									
									[self.contactTableView reloadData];
								}];
}

- (void)synchronizeFriends {
	NSMutableArray *facebookIds = [[NSMutableArray alloc] init];
	
	for (SLVFacebookFriend *facebookFriend in self.unsynchronizedFacebookContacts) {
		if (facebookFriend.facebookId) {
			[facebookIds addObject:facebookFriend.facebookId];
		}
	}
	
	[PFCloud callFunctionInBackground:SYNCHRONIZE_CONTACTS_FUNCTION
					   withParameters:@{@"facebookIds" : facebookIds}
								block:^(id object, NSError *error){
									if (!error) {
										self.synchronizedFacebookContacts = [[NSArray alloc] init];
										
										NSDictionary *datas = object;
										NSArray *registeredContacts = [datas objectForKey:@"registeredContacts"];
										
										if (registeredContacts && [registeredContacts count] > 0) {
											for (NSDictionary *registeredContact in registeredContacts) {
												NSString *username = [registeredContact objectForKey:@"username"];
												
												if (![username isEqualToString:[PFUser currentUser].username]) {
													for (SLVFacebookFriend *facebookContact in self.unsynchronizedFacebookContacts) {
														if ([facebookContact.facebookId isEqualToString:[registeredContact objectForKey:@"facebookId"]]) {
															facebookContact.username = username;
															
															NSString *pictureUrl = [registeredContact objectForKey:@"pictureUrl"];
															if (pictureUrl && ![pictureUrl isEqualToString:@""]) {
																facebookContact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
															}
															
															SLVLog(@"Contact '%@' synchronized with username '%@'", facebookContact.fullName, facebookContact.username);
															
															[self moveContactToSynchronizedArray:facebookContact];
														}
													}
												}
											}
											
											NSMutableArray *synchronizedAddressBookContactsBuffer = [self.synchronizedAddressBookContacts mutableCopy];
											self.synchronizedAddressBookContacts = [synchronizedAddressBookContactsBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
												return [a.fullName caseInsensitiveCompare:b.fullName];
											}];
											
											[self.contactTableView reloadData];
										}
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

- (void)moveContactToSynchronizedArray:(SLVContact *)contact {
	NSMutableArray *unsynchronizedAddressBookContactsBuffer = [self.unsynchronizedAddressBookContacts mutableCopy];
	[unsynchronizedAddressBookContactsBuffer removeObject:contact];
	self.unsynchronizedAddressBookContacts = unsynchronizedAddressBookContactsBuffer;
	
	NSMutableArray *synchronizedAddressBookContactsBuffer = [self.synchronizedAddressBookContacts mutableCopy];
	[synchronizedAddressBookContactsBuffer addObject:contact];
	self.synchronizedAddressBookContacts = synchronizedAddressBookContactsBuffer;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	switch (self.filterSegmentedControl.selectedSegmentIndex) {
		case kFavoriteFilter:
			return 1;
			
		case kAddressBookFilter:
			if ([self.synchronizedAddressBookContacts count] > 0) {
				return 2;
			} else {
				return 1;
			}
			
		case kFacebookFilter:
			if ([self.synchronizedFacebookContacts count] > 0) {
				return 2;
			} else {
				return 1;
			}
			
		default:
			return 1;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (self.filterSegmentedControl.selectedSegmentIndex) {
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
			
		case kFacebookFilter:
			if ([self.synchronizedFacebookContacts count] > 0) {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (self.filterSegmentedControl.selectedSegmentIndex) {
		case kFavoriteFilter:
			return [self.favoriteContacts count];
			
		case kAddressBookFilter:
			if (([self.synchronizedAddressBookContacts count] > 0) && (section == 0)) {
				return [self.synchronizedAddressBookContacts count];
			}
			return [self.unsynchronizedAddressBookContacts count];
			
		case kFacebookFilter:
			if (([self.synchronizedFacebookContacts count] > 0) && (section == 0)) {
				return [self.synchronizedFacebookContacts count];
			}
			return [self.unsynchronizedFacebookContacts count];
			
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
	
	switch (self.filterSegmentedControl.selectedSegmentIndex) {
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
			if (indexPath.section == 0 && [self.synchronizedFacebookContacts count] > 0) {
				contact = [self.synchronizedFacebookContacts objectAtIndex:indexPath.row];
			} else {
				contact = [self.unsynchronizedFacebookContacts objectAtIndex:indexPath.row];
			}
			break;
			
		default:
			contact = nil;
			break;
	}
	
	if (!contact) {
		return cell;
	}
	
	cell.fullNameLabel.text = contact.fullName;
	cell.pictureImageView.image = contact.picture;
	
	if (contact.username && ![contact.username isEqualToString:@""]) {
		cell.usernameLabel.text = contact.username;
	} else if ([contact isKindOfClass:[SLVAddressBookContact class]]) {
		SLVAddressBookContact *addressBookContact = (SLVAddressBookContact *)contact;
		
		if ([addressBookContact.phoneNumbers count] > 1) {
			cell.usernameLabel.text = NSLocalizedString(@"label_several_phone_numbers", nil);
		} else {
			NSDictionary *phoneNumberDic = [addressBookContact.phoneNumbers firstObject];
			NSString *formatedPhoneNumber = [phoneNumberDic objectForKey:@"formatedPhoneNumber"];
			NSString *phoneNumber = [phoneNumberDic objectForKey:@"phoneNumber"];
			
			if (formatedPhoneNumber && [formatedPhoneNumber length] >= 6) {
				if ([[formatedPhoneNumber substringToIndex:5] isEqualToString:@"error"]) {
					cell.usernameLabel.text = NSLocalizedString(formatedPhoneNumber, nil);
					
					SLVLog(@"%@Phone number '%@' couldn't be formated with country code '%@'", SLV_ERROR, phoneNumber, ApplicationDelegate.userCountryCodeData);
				} else {
					cell.usernameLabel.text = phoneNumber;
				}
			} else {
				cell.usernameLabel.text = NSLocalizedString(formatedPhoneNumber, nil);
				
				SLVLog(@"%@Formated phone number reception for '%@' failed without displaying an error!", SLV_ERROR, phoneNumber);
			}
		}
	} else if ([contact isKindOfClass:[SLVFacebookFriend class]]) {
		cell.usernameLabel.text = @"";
	}
	
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.layer.cornerRadius = cell.pictureImageView.bounds.size.height / 2;
	cell.pictureImageView.clipsToBounds = YES;
	
	[SLVViewController setStyle:cell];
	
	cell.fullNameLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && [self.synchronizedAddressBookContacts count] > 0) {
		SLVLog(@"Selected %@", [[self.synchronizedAddressBookContacts objectAtIndex:indexPath.row] description]);
	} else {
		SLVLog(@"Selected %@", [[self.unsynchronizedAddressBookContacts objectAtIndex:indexPath.row] description]);
	}
}

@end
