//
//  SLVProfileViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import "SLVContact.h"

@interface SLVProfileViewController : SLVViewController

@property (strong, nonatomic) SLVContact *contact;
@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sloveCounterLabel;
@property (strong, nonatomic) IBOutlet UIButton *sloveButton;

- (id)initWithContact:(SLVContact *)contact;
- (IBAction)sloveAction:(id)sender;

@end