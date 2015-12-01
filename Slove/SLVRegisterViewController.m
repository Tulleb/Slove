//
//  SLVRegisterViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 25/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVRegisterViewController.h"
#import "SLVPhoneNumberViewController.h"

@interface SLVRegisterViewController ()

@end

@implementation SLVRegisterViewController

- (void)viewDidLoad {
	self.appName = @"register";
	
    [super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/inscription_mail_banniere"];
	
	self.emailField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	self.usernameField.background = [UIImage imageNamed:@"Assets/Box/input1"];
	self.passwordField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.registerButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox"] forState:UIControlStateNormal];
	[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox_clic"] forState:UIControlStateHighlighted];
	
	self.errorLabel.textColor = RED;
	
	[self loadBackButton];
	
	[self observeKeyboard];
	[self initTapToDismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)conditionsAction:(id)sender {
	conditionsAccepted = !conditionsAccepted;
	
	if (conditionsAccepted) {
		[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox_clic"] forState:UIControlStateNormal];
		[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox"] forState:UIControlStateHighlighted];
	} else {
		[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox"] forState:UIControlStateNormal];
		[self.conditionsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/checkbox_clic"] forState:UIControlStateHighlighted];
	}
}

- (void)trimUsernameField {
	NSString *trimmedUsername = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	self.usernameField.text = trimmedUsername;
}

- (IBAction)registerAction:(id)sender {
	[self hideKeyboard];
	
	self.errorLabel.hidden = YES;
	
	self.usernameField.text = [SLVTools trimUsername:self.usernameField.text];
	
	NSString *answer = [SLVTools validateEmail:self.emailField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	answer = [SLVTools validateUsername:self.usernameField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	answer = [SLVTools validatePassword:self.passwordField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	answer = [SLVTools validateConditions:conditionsAccepted];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	[self registerUser];
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
		
		CGFloat height = keyboardFrame.size.height;
		
		if (self.bodyView.frame.origin.y - height >= 0) {
			NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
			
			self.keyboardLayoutConstraint.constant += height;
			
			[UIView animateWithDuration:animationDuration animations:^{
				[self.view layoutIfNeeded];
			}];
		} else {
			if (!self.screenIsTooSmall) {
				self.screenIsTooSmall = YES;
				
				// We have to repeat this once because this function is called after shouldBeginEditing
				if ([self.emailField isFirstResponder]) {
					self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.emailField.frame.origin.y - self.emailField.frame.size.height;
				} else if ([self.usernameField isFirstResponder]) {
					self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.usernameField.frame.origin.y - self.usernameField.frame.size.height;
				} else if ([self.passwordField isFirstResponder]) {
					self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.passwordField.frame.origin.y - self.passwordField.frame.size.height;
				}
				
				[UIView animateWithDuration:ANIMATION_DURATION animations:^{
					[self.view layoutIfNeeded];
				}];
			}
		}
		
		self.keyboardIsVisible = YES;
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		
		if (!self.screenIsTooSmall) {
			NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
			
			self.keyboardLayoutConstraint.constant = 8;
			
			[UIView animateWithDuration:animationDuration animations:^{
				[self.view layoutIfNeeded];
			}];
		}
		
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
	for (UITextField *textField in self.bodyView.subviews) {
		[textField resignFirstResponder];
	}
}

- (void)registerUser {
	PFUser *user = [PFUser user];
	user.username = self.usernameField.text;
	user.password = self.passwordField.text;
	user.email = self.emailField.text;
	
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (!error) {
			SLVPhoneNumberViewController *viewController = [[SLVPhoneNumberViewController alloc] init];
			[self.navigationController pushViewController:viewController animated:YES];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.emailField) {
		[self.usernameField becomeFirstResponder];
	} else if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.emailField || textField == self.passwordField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2_clic"];
	} else if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input1_clic"];
	}
	
	if (self.screenIsTooSmall) {
		if (textField == self.emailField) {
			self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.emailField.frame.origin.y - self.emailField.frame.size.height;
		} else if (textField == self.usernameField) {
			self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.usernameField.frame.origin.y - self.usernameField.frame.size.height;
		} else if (textField == self.passwordField) {
			self.keyboardLayoutConstraint.constant = self.bodyView.frame.size.height - self.passwordField.frame.origin.y - self.passwordField.frame.size.height;
		}
		
		[UIView animateWithDuration:ANIMATION_DURATION animations:^{
			[self.view layoutSubviews];
		}];
	}
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == self.emailField || textField == self.passwordField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	} else if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input1"];
	}
	
	return YES;
}

@end
