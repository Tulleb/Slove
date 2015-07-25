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
	self.appName = @"Register";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// To substract the navigation bar height from the view
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
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
		[self.conditionsButton setTitle:@"OK" forState:UIControlStateNormal];
	} else {
		[self.conditionsButton setTitle:@"KO" forState:UIControlStateNormal];
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
	
	NSString *answer = [SLVTools validateUsername:self.usernameField.text];
	if(![answer isEqualToString:VALIDATION_ANSWER_KEY]) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = answer;
		
		return;
	}
	
	answer = [SLVTools validateEmail:self.emailField.text];
	if(![answer isEqualToString:VALIDATION_ANSWER_KEY]) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = answer;
		
		return;
	}
	
	answer = [SLVTools validatePassword:self.passwordField.text];
	if(![answer isEqualToString:VALIDATION_ANSWER_KEY]) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = answer;
		
		return;
	}
	
	answer = [SLVTools validateConditions:conditionsAccepted];
	if(![answer isEqualToString:VALIDATION_ANSWER_KEY]) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = answer;
		
		return;
	}
	
	self.errorLabel.hidden = NO;
	
	[self registerUser];
}

- (void)observeKeyboard {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [kbFrame CGRectValue];
 
	CGFloat height = keyboardFrame.size.height;

	self.keyboardConstraint.constant += height;
	
	[UIView animateWithDuration:animationDuration animations:^{
		[self.view layoutIfNeeded];
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
 
	self.keyboardConstraint.constant = 8;
	
	[UIView animateWithDuration:animationDuration animations:^{
		[self.view layoutIfNeeded];
	}];
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

- (void)registerUser {
	PFUser *user = [PFUser user];
	user.username = self.usernameField.text;
	user.password = self.passwordField.text;
	user.email = self.emailField.text;
	
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (!error) {
			[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		}
	}];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.usernameField) {
		[self.emailField becomeFirstResponder];
	} else if (textField == self.emailField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end
