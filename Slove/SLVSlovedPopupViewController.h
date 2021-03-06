//
//  SLVSlovedPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"
#import "SLVContact.h"

@interface SLVSlovedPopupViewController : SLVPopupViewController

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UIImageView *layerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *unknownPuppyImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet UIView *disablingView;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) SLVContact *slover;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *pictureHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleLabelTopLayoutConstraint;
@property (strong, nonatomic) UIImage *pictureImage;

- (id)initWithContact:(SLVContact *)contact andPicture:(UIImage *)picture;
- (IBAction)leftAction:(id)sender;
- (IBAction)rightAction:(id)sender;

@end
