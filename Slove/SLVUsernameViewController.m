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
	
	[self loadBackButton];
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
