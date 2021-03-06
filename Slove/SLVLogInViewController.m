//
//  SLVLogInViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 26/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVLogInViewController.h"
#import "SLVPhoneNumberViewController.h"

@interface SLVLogInViewController ()

@end

@implementation SLVLogInViewController

- (id)initWithForcedLogIn {
	self = [super init];
	if (self) {
		[self.navigationItem setHidesBackButton:YES];
	}
	return self;
}

- (void)viewDidLoad {
	self.appName = @"log_in";
	
    [super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/inscription_mail_banniere"];
	
	self.usernameField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	self.passwordField.background = [UIImage imageNamed:@"Assets/Box/input1"];
	
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	self.errorLabel.textColor = RED;
	
	[self observeKeyboard];
	[self initTapToDismiss];
	
	[self loadBackButton];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationItem setHidesBackButton:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInAction:(id)sender {
	self.errorLabel.hidden = YES;
	[self hideKeyboard];
	
	NSString *answer = [SLVTools usernameIsFilled:self.usernameField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	answer = [SLVTools passwordIsFilled:self.passwordField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	[PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
		if (!error) {
			if ([user objectForKey:@"phoneNumber"] == nil) {
				[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
			} else {
				[ApplicationDelegate userConnected];
			}
		} else {
			self.errorLabel.hidden = NO;
			self.errorLabel.text = NSLocalizedString(@"error_login_doesnt_match", nil);
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

- (void)observeKeyboard {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)notification {
	if (!self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
		CGRect keyboardFrame = [kbFrame CGRectValue];
		
		self.keyboardHeight = keyboardFrame.size.height;
		
		CGRect lastTextFieldFrame = self.passwordField.frame;
		float remainingSpace = SCREEN_HEIGHT - self.view.frame.origin.y - (lastTextFieldFrame.origin.y + lastTextFieldFrame.size.height) - self.keyboardHeight;
		
		if (remainingSpace < 0 && !self.screenIsTooSmall) {
			self.screenIsTooSmall = YES;
			
			// We have to repeat this once because this function is called after shouldBeginEditing
			if ([self.usernameField isFirstResponder]) {
				[self.view removeConstraint:self.keyboardLayoutConstraint];
				self.keyboardLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.view
																			 attribute:NSLayoutAttributeBottom
																			 relatedBy:NSLayoutRelationEqual
																				toItem:self.usernameField
																			 attribute:NSLayoutAttributeBottom
																			multiplier:1
																			  constant:60 + self.keyboardHeight];
				[self.view addConstraint:self.keyboardLayoutConstraint];
			} else if ([self.passwordField isFirstResponder]) {
				[self.view removeConstraint:self.keyboardLayoutConstraint];
				self.keyboardLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.view
																			 attribute:NSLayoutAttributeBottom
																			 relatedBy:NSLayoutRelationEqual
																				toItem:self.passwordField
																			 attribute:NSLayoutAttributeBottom
																			multiplier:1
																			  constant:20 + self.keyboardHeight];
				[self.view addConstraint:self.keyboardLayoutConstraint];
			}
		} else if (!self.screenIsTooSmall) {
			self.keyboardLayoutConstraint.constant += self.keyboardHeight;
		}
		
		[UIView animateWithDuration:SHORT_ANIMATION_DURATION animations:^{
			[self.view layoutIfNeeded];
		}];
		
		self.keyboardIsVisible = YES;
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		
		NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		
		[self.view removeConstraint:self.keyboardLayoutConstraint];
		self.keyboardLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.view
																	 attribute:NSLayoutAttributeBottom
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.registerButton
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1
																	  constant:8];
		[self.view addConstraint:self.keyboardLayoutConstraint];
		
		[UIView animateWithDuration:animationDuration animations:^{
			[self.view layoutIfNeeded];
		}];
		
		self.keyboardIsVisible = NO;
	}
}

- (void)initTapToDismiss {
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
										   initWithTarget:self
										   action:@selector(hideKeyboard)];
	
	[self.view addGestureRecognizer:tapGesture];
}

- (void)hideKeyboard {
	for (UITextField *textField in self.view.subviews) {
		[textField resignFirstResponder];
	}
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2_clic"];
	} else if (textField == self.passwordField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input1_clic"];
	}
	
	if (self.screenIsTooSmall) {
		if (textField == self.usernameField) {
			[self.view removeConstraint:self.keyboardLayoutConstraint];
			self.keyboardLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.view
																	  attribute:NSLayoutAttributeBottom
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:self.usernameField
																	  attribute:NSLayoutAttributeBottom
																	 multiplier:1
																	   constant:60 + self.keyboardHeight];
			[self.view addConstraint:self.keyboardLayoutConstraint];
		} else if (textField == self.passwordField) {
			[self.view removeConstraint:self.keyboardLayoutConstraint];
			self.keyboardLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.view
																		 attribute:NSLayoutAttributeBottom
																		 relatedBy:NSLayoutRelationEqual
																			toItem:self.passwordField
																		 attribute:NSLayoutAttributeBottom
																		multiplier:1
																		  constant:20 + self.keyboardHeight];
			[self.view addConstraint:self.keyboardLayoutConstraint];
		}
		
		[UIView animateWithDuration:SHORT_ANIMATION_DURATION animations:^{
			[self.view layoutSubviews];
		}];
	}
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	} else if (textField == self.passwordField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input1"];
	}
	
	return YES;
}

@end
