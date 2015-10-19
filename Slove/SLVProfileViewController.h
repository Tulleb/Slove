//
//  SLVProfileViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVProfileViewController : SLVViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *bannerView;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *levelImageView;
@property (strong, nonatomic) IBOutlet UIView *counterView;
@property (strong, nonatomic) IBOutlet UIImageView *counterImageView;
@property (strong, nonatomic) IBOutlet UILabel *counterLabel;
@property (strong, nonatomic) IBOutlet UIView *bodyView;
@property (strong, nonatomic) IBOutlet UIImageView *topBarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomBarImageView;
@property (strong, nonatomic) IBOutlet UIButton *disconnectButton;
@property (strong, nonatomic) IBOutlet UIButton *uploadProfilePictureButton;
@property (strong, nonatomic) IBOutlet UIView *contactView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureLayerImageView;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pictoImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomDictonnectButtonLayoutConstraint;

- (IBAction)uploadProfilePictureAction:(id)sender;
- (IBAction)disconnectAction:(id)sender;

@end
