//
//  SLVHomeViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import <AddressBookUI/AddressBookUI.h>

typedef enum  {
	kFavoriteFilter,
	kAddressBookFilter,
	kFacebookFilter
} FilterSegment;

@interface SLVHomeViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UIButton *accessContactsButton;
@property (strong, nonatomic) IBOutlet UIButton *accessFriendsButton;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) NSArray *favoriteContacts;
@property (strong, nonatomic) NSArray *unsynchronizedAddressBookContacts;
@property (strong, nonatomic) NSArray *synchronizedAddressBookContacts;
@property (strong, nonatomic) NSArray *unsynchronizedFacebookContacts;
@property (strong, nonatomic) NSArray *synchronizedFacebookContacts;
@property (nonatomic) BOOL readyToDownload;
@property (nonatomic) BOOL pictureDownloaded;
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (nonatomic) FilterSegment currentFilter;
@property (nonatomic) int percentage;

- (IBAction)disconnectAction:(id)sender;
- (IBAction)accessContactAction:(id)sender;
- (IBAction)accessFriendsAction:(id)sender;
- (IBAction)filterChanged:(id)sender;

@end
