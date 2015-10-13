//
//  SLVPhoneNumberViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPhoneNumberViewController.h"
#import "SLVConfirmationCodeViewController.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "SLVRegisterViewController.h"

@interface SLVPhoneNumberViewController ()

@end

@implementation SLVPhoneNumberViewController

- (void)viewDidLoad {
	self.appName = @"phone_number";
	
    [super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/choix_pays_banniere"];
	self.bannerLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT_ITALIC size:DEFAULT_FONT_SIZE];
	self.bannerLabel.textColor = WHITE;
	
	self.pickerBackgroundImageView.image = [UIImage imageNamed:@"Assets/Image/degrade_choix_pays"];
	self.pickerTopImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
	self.pickerBottomImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
	
	self.phoneNumberField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt"] forState:UIControlStateNormal];
	[self.confirmButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_clic"] forState:UIControlStateHighlighted];
	
	self.errorLabel.textColor = RED;
	
	[self observeKeyboard];
	[self initTapToDismiss];
	
	NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
	
	if ((numberOfViewControllers >= 2) && [[self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2] isKindOfClass:[SLVRegisterViewController class]]) {
		self.navigationItem.hidesBackButton = YES;
	} else {
		[self loadBackButton];
	}
	
	self.navigationItem.hidesBackButton = YES;
	
	[self selectDefaultCountry];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.rightBannerLabelLayoutConstraint.constant = self.bannerImageView.frame.size.width * 0.45;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	self.errorLabel.hidden = YES;
	self.formatedPhoneNumber = nil;
	
	SLVCountryCodeData *selectedCountryCodeData = [ApplicationDelegate.countryCodeDatas objectAtIndex:[self.countryPickerView selectedRowInComponent:0]];
	self.formatedPhoneNumber = [SLVTools formatPhoneNumber:self.phoneNumberField.text withCountryCodeData:selectedCountryCodeData];
	
	if (self.formatedPhoneNumber && [self.formatedPhoneNumber length] >= 6) {
		if ([[self.formatedPhoneNumber substringToIndex:5] isEqualToString:@"error"]) {
			self.errorLabel.hidden = NO;
			self.errorLabel.text = NSLocalizedString(@"error_phone_number_format", nil);
			
			SLVLog(@"%@Phone number '%@' couldn't be formated with country code '%@'", SLV_ERROR, self.phoneNumberField.text, [selectedCountryCodeData description]);
			
			return;
		}
	} else {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = NSLocalizedString(@"error_phone_number_format", nil);
		
		SLVLog(@"%@Formated phone number reception for '%@' failed without displaying an error!", SLV_ERROR, self.phoneNumberField.text);
		return;
	}
	
	[PFCloud callFunctionInBackground:PHONENUMBER_SEND_FUNCTION
					   withParameters:@{@"phoneNumber" : self.formatedPhoneNumber}
								block:^(id object, NSError *error){
									if (!error) {
										if ([object objectForKey:@"body"]) {
											SLVLog(@"Received message: '%@'", [object objectForKey:@"body"]);
										}
										
										[self.navigationController pushViewController:[[SLVConfirmationCodeViewController alloc] initWithPhoneNumber:self.formatedPhoneNumber] animated:YES];
									} else {
										self.errorLabel.hidden = NO;
										self.errorLabel.text = NSLocalizedString(error.localizedDescription, nil);
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

- (void)selectDefaultCountry {
	if (ApplicationDelegate.userCountryCodeData) {
		[self.countryPickerView selectRow:[ApplicationDelegate.countryCodeDatas indexOfObject:ApplicationDelegate.userCountryCodeData] inComponent:0 animated:YES];
	}
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


# pragma mark - UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [ApplicationDelegate.countryCodeDatas count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	SLVCountryCodeData	*countryCodeData = [ApplicationDelegate.countryCodeDatas objectAtIndex:row];
	
	return [NSString stringWithFormat:@"%@ (+%@)", countryCodeData.country, countryCodeData.countryCode];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	UILabel *label = (UILabel *)view;
	if (!label) {
		label = [[UILabel alloc] init];
		label.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
		label.textAlignment = NSTextAlignmentCenter;
	}
	
	label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
	return label;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.phoneNumberField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2_clic"];
	}
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == self.phoneNumberField) {
		textField.background = [UIImage imageNamed:@"Assets/Box/input2"];
	}
	
	return YES;
}

@end
