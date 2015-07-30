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

@property (strong, nonatomic) IBOutlet UIButton *accessContactButton;
@property (strong, nonatomic) IBOutlet UITableView *addressContactTableView;
@property (strong, nonatomic) NSArray *addressBook;

- (IBAction)disconnectAction:(id)sender;
- (IBAction)accessContactAction:(id)sender;

@end
