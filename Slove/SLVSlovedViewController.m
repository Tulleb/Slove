//
//  SLVSlovedViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSlovedViewController.h"
#import "SLVSloveSentViewController.h"

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
	
	self.pictureImageView.image = self.slover.picture;
	self.layerImageView.image = [UIImage imageNamed:@"Assets/Image/notif_masque"];
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notif"] forState:UIControlStateNormal];
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notifclic"] forState:UIControlStateHighlighted];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif"] forState:UIControlStateNormal];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif_clic"] forState:UIControlStateHighlighted];
	
	[self.leftButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.rightButton setTitleColor:WHITE forState:UIControlStateNormal];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
	self.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	
	self.subtitleLabel.text = [self.subtitleLabel.text stringByAppendingString:self.slover.username];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)leftAction:(id)sender {
	[PFCloud callFunctionInBackground:SEND_SLOVE_FUNCTION
					   withParameters:@{@"username" : self.slover.username}
								block:^(id object, NSError *error){
									if (!error) {
										[SLVTools playSound:SLOVER_SOUND];
										
										[[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
											SLVSloveSentViewController *presentedViewController = [[SLVSloveSentViewController alloc] init];
											[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
											
											[ApplicationDelegate.currentNavigationController refreshSloveCounter];
										}];
									} else {
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
										
										[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
									}
								}];
}

- (IBAction)rightAction:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
