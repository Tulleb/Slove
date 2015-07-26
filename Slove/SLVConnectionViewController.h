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

@interface SLVConnectionViewController : SLVViewController <FBSDKLoginButtonDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;

- (IBAction)connectAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
