//
//  SLVHomeViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SLVHomeViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSegmentedControl;
@property (strong, nonatomic) IBOutlet UIButton *accessContactsButton;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
@property (strong, nonatomic) NSArray *unsynchronizedContacts;
@property (strong, nonatomic) NSArray *synchronizedContacts;
@property (nonatomic) ABAddressBookRef addressBookRef;

- (IBAction)disconnectAction:(id)sender;
- (IBAction)accessContactAction:(id)sender;
- (IBAction)filterChanged:(id)sender;

@end
