//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"
#import "SLVSloveSentViewController.h"

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
    [super viewDidLoad];
	
	if (self.contact.username && ![self.contact.username isEqualToString:@""]) {
		self.title = self.contact.username;
	} else {
		self.title = self.contact.fullName;
	}
	
	self.spiraleImageView.image = [UIImage imageNamed:@"Assets/Button/bt_spirale_rotation"];
	
	self.spiraleYConstraint.constant = (self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) / 2;
	
	[self loadBackButton];
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

- (void)viewDidDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = NO;
	
	[super viewDidDisappear:animated];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	UIImage *_maskingImage = [UIImage imageNamed:@"Assets/Layer/layer_profile_picture"];
	CALayer *_maskingLayer = [CALayer layer];
	_maskingLayer.frame = self.pictureImageView.bounds;
	[_maskingLayer setContents:(id)[_maskingImage CGImage]];
	[self.pictureImageView.layer setMask:_maskingLayer];
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
										SLVSloveSentViewController *presentedViewController = [[SLVSloveSentViewController alloc] init];
										[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
										
										[SLVTools playSound:CONNECTION_VIEW_SOUND];
										
										[ApplicationDelegate.currentNavigationController refreshSloveCounter];
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

@end
