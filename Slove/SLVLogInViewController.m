//
//  SLVLogInViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 26/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVLogInViewController.h"

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
	self.appName = @"Log In";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// To substract the navigation bar height from the view
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	[self observeKeyboard];
	[self initTapToDismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationItem setHidesBackButton:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInAction:(id)sender {
	[self hideKeyboard];
	
	[PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
		if (!error) {
			[ApplicationDelegate userIsConnected];
		} else {
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


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.usernameField) {
		[self.passwordField becomeFirstResponder];
	} else if (textField == self.passwordField) {
		[self logInAction:self.logInButton];
	}
	
	return YES;
}

@end
