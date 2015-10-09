//
//  SLVAddSloverViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/09/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import "SLVInteractionPopupViewController.h"
#import "SLVHomeViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SLVAddSloverViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SLVInteractionPopupDelegate>

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;
@property (strong, nonatomic) IBOutlet UITableView *sloverTableView;
@property (strong, nonatomic) IBOutlet UIButton *facebookFriendsButton;
@property (strong, nonatomic) IBOutlet UIButton *addressBookButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) SLVInteractionPopupViewController *followedPopup;
@property (strong, nonatomic) NSArray *sloversFound;
@property (strong, nonatomic) SLVHomeViewController *homeViewController;
@property (nonatomic) ABAddressBookRef addressBookRef;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sloverTableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addressBookBottomLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *facebookBottomLayoutConstraint;

- (id)initWithHomeViewController:(SLVHomeViewController *)homeViewController;
- (IBAction)facebookFriendsAction:(id)sender;
- (IBAction)contactBookAction:(id)sender;

@end
