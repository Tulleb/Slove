//
//  SLVRegisterViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 25/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVRegisterViewController : SLVViewController <UITextFieldDelegate> {
	BOOL conditionsAccepted;
}

@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UIView *bodyView;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *conditionsButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic) BOOL keyboardIsVisible;
@property (nonatomic) BOOL screenIsTooSmall;

- (IBAction)conditionsAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
