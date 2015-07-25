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
	self.appName = @"Phone Number";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	NSError *error;
	
	NSDictionary *response = [PFCloud callFunction:PHONENUMBER_SEND_FUNCTION
		   withParameters:@{@"phoneNumber" : self.phoneNumberField.text}
					error:&error];
	
	if (!error) {
		if ([response objectForKey:@"body"]) {
			NSLog(@"Received message: '%@'", [response objectForKey:@"body"]);
		}
		
		[self.navigationController pushViewController:[[SLVConfirmationCodeViewController alloc] initWithPhoneNumber:self.phoneNumberField.text] animated:YES];
	} else {
		// TODO: Handle errors
		SLVLog(@"%@%@", SLV_ERROR, error.description);
	}
}

@end
