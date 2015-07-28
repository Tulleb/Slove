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
		currentPhoneNumber = phoneNumber;
	}
	
	return self;
}

- (void)viewDidLoad {
	self.appName = @"Confirmation Code";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	self.errorLabel.hidden = YES;
	
	[PFCloud callFunctionInBackground:PHONENUMBER_CONFIRM_FUNCTION
					   withParameters:@{@"phoneNumber" : currentPhoneNumber, @"phoneVerificationCode" : self.confirmationNumberField.text}
								block:^(id object, NSError *error){
									if (!error) {
										[ApplicationDelegate userConnected];
									} else {
										self.errorLabel.hidden = NO;
										self.errorLabel.text = error.localizedDescription;
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

@end
