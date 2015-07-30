//
//  SLVPhoneNumberViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPhoneNumberViewController.h"
#import "SLVConfirmationCodeViewController.h"

@interface SLVPhoneNumberViewController ()

@end

@implementation SLVPhoneNumberViewController

- (void)viewDidLoad {
	self.appName = @"phone_number";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	self.errorLabel.hidden = YES;
	
	[PFCloud callFunctionInBackground:PHONENUMBER_SEND_FUNCTION
					   withParameters:@{@"phoneNumber" : self.phoneNumberField.text}
								block:^(id object, NSError *error){
									if (!error) {
										if ([object objectForKey:@"body"]) {
											NSLog(@"Received message: '%@'", [object objectForKey:@"body"]);
										}
										
										[self.navigationController pushViewController:[[SLVConfirmationCodeViewController alloc] initWithPhoneNumber:self.phoneNumberField.text] animated:YES];
									} else {
										self.errorLabel.hidden = NO;
										self.errorLabel.text = NSLocalizedString(error.localizedDescription, nil);
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

@end
