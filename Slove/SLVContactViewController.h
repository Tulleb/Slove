//
//  SLVContactViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import "SLVContact.h"
#import <MessageUI/MessageUI.h>
#import <iCarousel/iCarousel.h>

@interface SLVContactViewController : SLVViewController <MFMessageComposeViewControllerDelegate, iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) SLVContact *contact;
@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UIImageView *spiraleImageView;
@property (strong, nonatomic) IBOutlet UIImageView *circleImageView;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bubblePicto;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *spiraleYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleLabelTopLayoutConstraint;
@property (strong, nonatomic) IBOutlet iCarousel *levelCarousel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *levelCarouselBottomLayoutConstraint;
@property (nonatomic) float spiraleAngle;

- (id)initWithContact:(SLVContact *)contact;
- (IBAction)sloveAction:(id)sender;

@end
