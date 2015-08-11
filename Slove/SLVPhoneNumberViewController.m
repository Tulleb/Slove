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

@interface SLVPhoneNumberViewController ()

@end

@implementation SLVPhoneNumberViewController

- (void)viewDidLoad {
	self.appName = @"phone_number";
	
    [super viewDidLoad];
	
	[self selectDefaultCountry];
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
			self.errorLabel.text = NSLocalizedString(self.formatedPhoneNumber, nil);
			
			SLVLog(@"%@Phone number '%@' couldn't be formated with country code '%@'", SLV_ERROR, self.phoneNumberField.text, [selectedCountryCodeData description]);
			
			self.formatedPhoneNumber = nil;
			
			return;
		}
	} else {
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

@end
