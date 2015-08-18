//
//  SLVSlovedViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSlovedViewController.h"

@interface SLVSlovedViewController ()

@end

@implementation SLVSlovedViewController

- (id)initWithContact:(SLVContact *)contact {
	self = [super init];
	if (self) {
		self.slover = contact;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.usernameLabel.text = self.slover.username;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okAction:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
