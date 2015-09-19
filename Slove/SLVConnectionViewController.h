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
#import "SLVInteractionPopupViewController.h"

@interface SLVConnectionViewController : SLVViewController <FBSDKLoginButtonDelegate, SLVInteractionPopupDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *layerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *titleImageView;
@property (strong, nonatomic) IBOutlet UILabel *subtitleUpperLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLowerLabel;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *usernameLoginButton;

- (IBAction)connectAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
