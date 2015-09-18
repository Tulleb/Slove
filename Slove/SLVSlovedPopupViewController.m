//
//  SLVSlovedPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSlovedPopupViewController.h"
#import "SLVSloveSentPopupViewController.h"
#import "SLVProfileViewController.h"

@interface SLVSlovedPopupViewController ()

@end

@implementation SLVSlovedPopupViewController

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
	self.bubbleImageView.image = [UIImage imageNamed:@"Assets/Image/infobulle_tuto_premierevisite_v2"];
	
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notif"] forState:UIControlStateNormal];
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notif_clic"] forState:UIControlStateHighlighted];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif"] forState:UIControlStateNormal];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif_clic"] forState:UIControlStateHighlighted];
	
	[self.leftButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.rightButton setTitleColor:WHITE forState:UIControlStateNormal];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
	self.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	
	self.subtitleLabel.text = [self.subtitleLabel.text stringByAppendingString:self.slover.username];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:KEY_FIRSTTIME_TUTORIAL] boolValue]) {
		self.disablingView.hidden = NO;
		self.bubbleView.hidden = NO;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.pictureHeightLayoutConstraint.constant = SCREEN_HEIGHT * 0.47;
	self.bubbleLabelTopLayoutConstraint.constant = SCREEN_HEIGHT * 0.05;
}

- (IBAction)leftAction:(id)sender {
	ApplicationDelegate.sloverToSlove = self.slover;
	
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SLOVEDPOPUP_DISMISSED
															object:nil
														  userInfo:nil];
		
		[self.navigationController popToRootViewControllerAnimated:NO];
	}];
}

- (IBAction)rightAction:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end