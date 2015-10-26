//
//  SLVConfirmationCodeViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVConfirmationCodeViewController.h"

@interface SLVConfirmationCodeViewController ()

@end

@implementation SLVConfirmationCodeViewController

- (id)initWithPhoneNumber:(NSString *)phoneNumber {
	self = [super init];
	
	if (self) {
		self.currentPhoneNumber = phoneNumber;
	}
	
	return self;
}

- (void)viewDidLoad {
	self.appName = @"confirmation_code";
	
    [super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/code_tel_banniere"];
	self.bannerLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT_ITALIC size:DEFAULT_FONT_SIZE];
	self.bannerLabel.textColor = WHITE;
	
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	self.errorLabel.textColor = RED;
	
	[self observeKeyboard];
	[self initTapToDismiss];
	
	[self loadBackButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.confirmationNumberField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.leftBannerLabelLayoutConstraint.constant = self.bannerImageView.frame.size.width * 0.45;
	
	self.confirmationNumberField.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:self.confirmationNumberField.frame.size.width / 2.33];
}

- (IBAction)confirmAction:(id)sender {
	self.errorLabel.hidden = YES;
	
	[PFCloud callFunctionInBackground:PHONENUMBER_CONFIRM_FUNCTION
					   withParameters:@{@"phoneNumber" : self.currentPhoneNumber, @"phoneVerificationCode" : self.confirmationNumberField.text}
								block:^(id object, NSError *error){
									if (!error) {
										SLVLog(@"Received data from server: %@", object);
										
										[ApplicationDelegate userConnected];
									} else {
										self.errorLabel.hidden = NO;
										self.errorLabel.text = NSLocalizedString(error.localizedDescription, nil);
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return !([textField.text length] >= 4 && [string length] > range.length);
}

@end
