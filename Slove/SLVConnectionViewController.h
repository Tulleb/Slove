//
//  SLVConnectionViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SLVInteractionPopupViewController.h"

@interface SLVConnectionViewController : SLVViewController <FBSDKLoginButtonDelegate, InteractionPopupDelegate> {
	AVAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleUpperLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLowerLabel;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *subtitleViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *footerViewHeightConstraint;

- (IBAction)connectAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
