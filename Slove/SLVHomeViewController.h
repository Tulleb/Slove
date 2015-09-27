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

@interface SLVHomeViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate, SLVInteractionPopupDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) IBOutlet UIImageView *pullImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pullTopLayoutConstraint;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *unsynchronizedContacts;
@property (strong, nonatomic) NSArray *synchronizedContacts;
@property (strong, nonatomic) NSArray *fullUnsynchronizedContacts;
@property (strong, nonatomic) NSArray *fullSynchronizedContacts;
@property (strong, nonatomic) NSArray *addressBookContacts;
@property (strong, nonatomic) NSArray *facebookContacts;
@property (strong, nonatomic) NSArray *followedContacts;
@property (nonatomic) BOOL refreshByPulling;
@property (nonatomic) BOOL isAlreadyLoading;
@property (nonatomic) BOOL addressBookContactsReady;
@property (nonatomic) BOOL facebookContactsReady;
@property (nonatomic) BOOL followedContactsReady;
@property (strong, nonatomic) SLVInteractionPopupViewController *addressBookPopup;
@property (strong, nonatomic) SLVInteractionPopupViewController *facebookPopup;
@property (nonatomic) BOOL readyToDownload;
@property (nonatomic) BOOL pictureDownloaded;
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (nonatomic) int percentage;
@property (nonatomic) BOOL popupIsDisplayed;

- (void)showSettingManipulation;
- (void)askFacebookFriends;

@end
