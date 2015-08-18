//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"

@interface SLVProfileViewController ()

@end

@implementation SLVProfileViewController

- (id)initWithContact:(SLVContact *)contact {
	self = [super init];
	
	if (self) {
		self.contact = contact;
	}
	
	return self;
}

- (void)viewDidLoad {
	self.appName = @"profile";
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.contact) {
		self.fullNameLabel.text = self.contact.fullName;
		
		if (self.contact.username && ![self.contact.username isEqualToString:@""]) {
			self.usernameLabel.hidden = NO;
			self.sloveCounterLabel.hidden = NO;
			self.sloveButton.hidden = NO;
			
			self.usernameLabel.text = self.contact.username;
			self.sloveCounterLabel.text = [self.contact.sloveCounter stringValue];
		} else {
			self.usernameLabel.hidden = YES;
			self.sloveCounterLabel.hidden = YES;
			self.sloveButton.hidden = YES;
		}
		
		if (self.contact.picture) {
			self.pictureImageView.hidden = NO;
			
			self.pictureImageView.image = self.contact.picture;
			self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
			self.pictureImageView.clipsToBounds = YES;
		} else {
			self.pictureImageView.hidden = YES;
		}
	}
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	self.pictureImageView.layer.cornerRadius = self.pictureImageView.bounds.size.height / 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sloveAction:(id)sender {
	[PFCloud callFunctionInBackground:SEND_SLOVE_FUNCTION
					   withParameters:@{@"username" : self.contact.username}
								block:^(id object, NSError *error){
									if (!error) {
										
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

@end
