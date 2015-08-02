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
#import "SLVContactTableViewCell.h"

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
	
	if ([self checkAddressBookAccessAuthorization]) {
		if (!self.unsynchronizedContacts) {
			self.addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
			[self loadContacts];
		}
	}
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
				[self loadAddressBookFromAddressBookRef:self.addressBookRef];
			} else {
				[self showSettingManipulation];
			}
		});
	}
}

- (IBAction)filterChanged:(id)sender {
}

- (void)loadContacts {
	[self loadAddressBookFromAddressBookRef:self.addressBookRef];
	[self synchronizeContacts];
}

- (BOOL)checkAddressBookAccessAuthorization {
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		return YES;
	} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
		[self showSettingManipulation];
	}
	
	return NO;
}

- (void)showSettingManipulation {
	SLVLog(@"%@User denied the access to his address book", SLV_ERROR);
}

- (void)loadAddressBookFromAddressBookRef:(ABAddressBookRef)addressBookRef {
	SLVLog(@"Loading user contacts from his address book");
	
	self.accessContactsButton.hidden = YES;
	
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
	
	self.unsynchronizedContacts = [addressBookBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
	
	[self.contactTableView reloadData];
	self.contactTableView.hidden = NO;
}

- (void)synchronizeContacts {
	NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
	
	for (SLVContact *contact in self.unsynchronizedContacts) {
		if ([contact isKindOfClass:[SLVAddressBookContact class]]) {
			SLVAddressBookContact *addressBookContact = (SLVAddressBookContact *)contact;
			
			for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
				[phoneNumbers addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
			}
		}
	}
	
	[PFCloud callFunctionInBackground:SYNCHRONIZE_CONTACTS_FUNCTION
					   withParameters:@{@"phoneNumbers" : phoneNumbers}
								block:^(id object, NSError *error){
									if (!error) {
										self.synchronizedContacts = [[NSArray alloc] init];
										
										NSDictionary *datas = object;
										NSArray *registeredContacts = [datas objectForKey:@"registeredContacts"];
										
										if (registeredContacts && [registeredContacts count] > 0) {
											for (NSDictionary *registeredContact in registeredContacts) {
												NSString *username = [registeredContact objectForKey:@"username"];
												
												if (![username isEqualToString:[PFUser currentUser].username]) {
													for (SLVContact *contact in self.unsynchronizedContacts) {
														if ([contact isKindOfClass:[SLVAddressBookContact class]]) {
															SLVAddressBookContact *addressBookContact = (SLVAddressBookContact *)contact;
															
															for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
																if ([[phoneNumberDic objectForKey:@"formatedPhoneNumber"] isEqualToString:[registeredContact objectForKey:@"phoneNumber"]]) {
																	contact.username = username;
																	
																	NSString *pictureUrl = [registeredContact objectForKey:@"pictureUrl"];
																	if (pictureUrl && ![pictureUrl isEqualToString:@""]) {
																		contact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
																	}
																	
																	SLVLog(@"Contact '%@' synchronized with username '%@'", contact.fullName, contact.username);
																	
																	[self moveContactToSynchronizedArray:contact];
																}
															}
														}
													}
												}
											}
											
											NSMutableArray *synchronizedContactsBuffer = [self.synchronizedContacts mutableCopy];
											self.synchronizedContacts = [synchronizedContactsBuffer sortedArrayUsingComparator:^(SLVContact *a, SLVContact *b) {
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
	NSMutableArray *unsynchronizedContactsBuffer = [self.unsynchronizedContacts mutableCopy];
	[unsynchronizedContactsBuffer removeObject:contact];
	self.unsynchronizedContacts = unsynchronizedContactsBuffer;
	
	NSMutableArray *synchronizedContactsBuffer = [self.synchronizedContacts mutableCopy];
	[synchronizedContactsBuffer addObject:contact];
	self.synchronizedContacts = synchronizedContactsBuffer;
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
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([self.synchronizedContacts count] > 0) {
		if (section == 0) {
			return [self.synchronizedContacts count];
		} else {
			return [self.unsynchronizedContacts count];
		}
	}
	
	return [self.unsynchronizedContacts count];
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
	if (indexPath.section == 0 && [self.synchronizedContacts count] > 0) {
		contact = [self.synchronizedContacts objectAtIndex:indexPath.row];
	} else {
		contact = [self.unsynchronizedContacts objectAtIndex:indexPath.row];
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
	}
	
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.layer.cornerRadius = cell.pictureImageView.bounds.size.height / 2;
	cell.pictureImageView.clipsToBounds = YES;
	
	[SLVViewController setStyle:cell];
	
	cell.fullNameLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && [self.synchronizedContacts count] > 0) {
		SLVLog(@"Selected %@", [[self.synchronizedContacts objectAtIndex:indexPath.row] description]);
	} else {
		SLVLog(@"Selected %@", [[self.unsynchronizedContacts objectAtIndex:indexPath.row] description]);
	}
}

@end
