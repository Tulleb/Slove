//
//  SLVUsernameViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 25/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVUsernameViewController.h"
#import "SLVPhoneNumberViewController.h"

@interface SLVUsernameViewController ()

@end

@implementation SLVUsernameViewController

- (void)viewDidLoad {
	self.appName = @"username";
	
    [super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/inscription_mail_banniere"];
	
	self.usernameField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	self.errorLabel.textColor = RED;
	
	[self loadBackButton];
	
	[self observeKeyboard];
	[self initTapToDismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	self.errorLabel.hidden = YES;
	
	self.usernameField.text = [SLVTools trimUsername:self.usernameField.text];
	
	NSString *answer = [SLVTools validateUsername:self.usernameField.text];
	if (answer) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(answer, nil);
		
		return;
	}
	
	[self saveUsername];
	
	[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
}

- (void)saveUsername {
	PFUser *user = [PFUser currentUser];
	user[@"username"] = self.usernameField.text;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (error) {
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
		NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		CGRect keyboardFrame = [kbFrame CGRectValue];
		
		CGFloat height = keyboardFrame.size.height;
		
		self.keyboardLayoutConstraint.constant += height;
		
		[UIView animateWithDuration:animationDuration animations:^{
			[self.view layoutIfNeeded];
		}];
		
		self.keyboardIsVisible = YES;
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	if (self.keyboardIsVisible) {
		NSDictionary *info = [notification userInfo];
		NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
		
		self.keyboardLayoutConstraint.constant = 8;
		
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2_clic"];
	}
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == self.usernameField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	}
	
	return YES;
}

@end
