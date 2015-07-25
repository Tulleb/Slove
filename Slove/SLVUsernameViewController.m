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
	self.appName = @"Username";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmAction:(id)sender {
	if([self validateUsername]) {
		[self registerUsername];
	}
}

- (BOOL)validateUsername {
	self.errorLabel.hidden = YES;
	self.errorLabel.text = @"";
	
	if (![self usernameIsValid]) {
		self.errorLabel.text = @"Can only contains alphanumerical and _ characters!";
		self.errorLabel.hidden = NO;
		
		return NO;
	}
	
	if (![self usernameIsFree]) {
		self.errorLabel.text = @"Username already exists!";
		self.errorLabel.hidden = NO;
		
		return NO;
	}
	
	return YES;
}

- (BOOL)usernameIsValid {
	return YES;
}

- (BOOL)usernameIsFree {
	PFQuery *query = [PFUser query];
	[query whereKey:@"username" equalTo:self.usernameField.text];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users name %@", SLV_WARNING, (unsigned long)[foundUsers count], self.usernameField.text);
		return NO;
	}
	
	return YES;
}

- (void)registerUsername {
	PFUser *user = [PFUser currentUser];
	user[@"username"] = self.usernameField.text;
	[user saveInBackground];
	
	if (user) {
		
	}
	[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
}

@end
