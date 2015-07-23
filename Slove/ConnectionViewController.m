//
//  ConnectionViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "ConnectionViewController.h"
#import "PhoneNumberViewController.h"

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([FBSDKAccessToken currentAccessToken]) {
		[self.navigationController pushViewController:[[PhoneNumberViewController alloc] init] animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectAction:(id)sender {
}

- (IBAction)subscribeAction:(id)sender {
}


#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
	// TODO: request get user
	if () {
		<#statements#>
	}
}

@end
