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
	self.errorLabel.hidden = YES;
	
	self.usernameField.text = [SLVTools trimUsername:self.usernameField.text];
	
	NSString *answer = [SLVTools validateUsername:self.usernameField.text];
	if(![answer isEqualToString:VALIDATION_ANSWER_KEY]) {
		self.errorLabel.hidden = NO;
		self.errorLabel.text = answer;
		
		return;
	}
	
	[self saveUsername];
	
	[self.navigationController pushViewController:[[SLVPhoneNumberViewController alloc] init] animated:YES];
}

- (void)saveUsername {
	PFUser *user = [PFUser currentUser];
	user[@"username"] = self.usernameField.text;
	[user saveInBackground];
}

@end
