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

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UIImageView *layerImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) SLVContact *slover;

- (id)initWithContact:(SLVContact *)contact;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;

@end
