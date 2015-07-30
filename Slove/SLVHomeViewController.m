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
		if (!self.addressBook) {
			ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
			[self loadAddressBookFromAddressBookRef:addressBookRef];
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
	ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
	
	if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
		SLVLog(@"Asking address book access to the user");
		ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
			if (granted) {
				[self loadAddressBookFromAddressBookRef:addressBookRef];
			} else {
				[self showSettingManipulation];
			}
		});
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

- (void)showSettingManipulation {
	SLVLog(@"%@User denied the access to his address book", SLV_ERROR);
}

- (void)loadAddressBookFromAddressBookRef:(ABAddressBookRef)addressBookRef {
	SLVLog(@"Loading user contacts from his address book");
	
	self.accessContactButton.hidden = YES;
	
	NSMutableArray *addressBookBuffer = [[NSMutableArray alloc] init];
	
	CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
	CFIndex contactCount = ABAddressBookGetPersonCount(addressBookRef);
	
	for (int i = 0; i < contactCount; i++) {
		ABRecordRef contact = CFArrayGetValueAtIndex(contacts, i);
		CFTypeRef firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
		CFTypeRef lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty);
		NSString *firstNameString = (NSString *)CFBridgingRelease(firstName);
		NSString *lastNameString = (NSString *)CFBridgingRelease(lastName);
		
		NSString *fullName = @"";
		if (firstName) {
			fullName = [fullName stringByAppendingString:firstNameString];
		}
		if (lastNameString) {
			if (![fullName isEqualToString:@""]) {
				fullName = [fullName stringByAppendingString:@" "];
			}
			fullName = [fullName stringByAppendingString:lastNameString];
		}
		
		if (![fullName isEqualToString:@""]) {
			CFDataRef imageData = ABPersonCopyImageData(contact);
			UIImage *image = [UIImage imageWithData:(NSData *)CFBridgingRelease(imageData)];
			
			ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(contact, kABPersonPhoneProperty);
			CFIndex phoneNumberCount = ABMultiValueGetCount(phoneNumbers);
			for (int j=0; j < phoneNumberCount; j++) {
				CFTypeRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, j);
				NSString *phoneNumberString = (NSString *)CFBridgingRelease(phoneNumber);
				
				SLVAddressBookContact *cachedContact = [[SLVAddressBookContact alloc] init];
				cachedContact.phoneNumber = phoneNumberString;
				cachedContact.fullName = fullName;
				cachedContact.picture = image;
				
				[addressBookBuffer addObject:cachedContact];
			}
		}
	}
	
	self.addressBook = [addressBookBuffer sortedArrayUsingComparator:^(SLVAddressBookContact *a, SLVAddressBookContact *b) {
		return [a.fullName caseInsensitiveCompare:b.fullName];
	}];
	
	[self.addressContactTableView reloadData];
	self.addressContactTableView.hidden = NO;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.addressBook count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"AddressBookContactCell";
	SLVContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"SLVContactTableViewCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
		cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	SLVAddressBookContact *contact = [self.addressBook objectAtIndex:indexPath.row];
	
	cell.fullNameLabel.text = contact.fullName;
	cell.pictureImageView.image = contact.picture;
	cell.usernameLabel.text = contact.phoneNumber;
	
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.layer.cornerRadius = cell.pictureImageView.bounds.size.height / 2;
	cell.pictureImageView.clipsToBounds = YES;
	
	[SLVViewController setStyle:cell];
	
	cell.fullNameLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	
	return cell;
}

@end
