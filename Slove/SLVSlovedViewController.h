//
//  SLVSlovedViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"
#import "SLVContact.h"

@interface SLVSlovedViewController : SLVPopupViewController

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) SLVContact *slover;

- (id)initWithContact:(SLVContact *)contact;
- (IBAction)okAction:(id)sender;

@end
