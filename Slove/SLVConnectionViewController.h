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

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)connectAction:(id)sender;
- (IBAction)subscribeAction:(id)sender;

@end
