//
//  SLVHomeViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SLVInteractionPopupViewController.h"
#import <MessageUI/MessageUI.h>

typedef enum  {
	kFavoriteFilter,
	kAddressBookFilter,
	kFacebookFilter
} FilterSegment;

@interface SLVHomeViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate, SLVInteractionPopupDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *filterBackgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) IBOutlet UIButton *contactButton;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) NSArray *favoriteContacts;
@property (strong, nonatomic) NSArray *unsynchronizedAddressBookContacts;
@property (strong, nonatomic) NSArray *synchronizedAddressBookContacts;
@property (strong, nonatomic) NSArray *facebookFriends;
@property (strong, nonatomic) NSArray *filterButtons;
@property (strong, nonatomic) SLVInteractionPopupViewController *errorPopup;
@property (strong, nonatomic) SLVInteractionPopupViewController *addressBookPopup;
@property (strong, nonatomic) SLVInteractionPopupViewController *facebookPopup;
@property (nonatomic) BOOL readyToDownload;
@property (nonatomic) BOOL pictureDownloaded;
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (nonatomic) FilterSegment currentFilter;
@property (nonatomic) int percentage;
@property (nonatomic) int selectedFilterIndex;

- (IBAction)filterChanged:(id)sender;

@end
