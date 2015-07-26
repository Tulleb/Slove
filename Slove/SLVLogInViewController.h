//
//  SLVLogInViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 26/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVLogInViewController : SLVViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardConstraint;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;

- (id)initWithForcedLogIn;
- (IBAction)logInAction:(id)sender;

@end
