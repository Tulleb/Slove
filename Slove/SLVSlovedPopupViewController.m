//
//  SLVSlovedPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 13/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSlovedPopupViewController.h"
#import "SLVSloveSentPopupViewController.h"
#import "SLVContactViewController.h"

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
	
	if (self.slover.picture) {
		self.pictureImageView.image = self.slover.picture;
	} else {
		self.pictureImageView.image = [UIImage imageNamed:@"Assets/Avatar/avatar_user_big"];
	}
	self.layerImageView.image = [UIImage imageNamed:@"Assets/Image/notif_masque"];
	self.bubbleImageView.image = [UIImage imageNamed:@"Assets/Image/infobulle_tuto_premierevisite_v2"];
	
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notif"] forState:UIControlStateNormal];
	[self.leftButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_gauche_notif_clic"] forState:UIControlStateHighlighted];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif"] forState:UIControlStateNormal];
	[self.rightButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_droite_notif_clic"] forState:UIControlStateHighlighted];
	
	[self.leftButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.rightButton setTitleColor:WHITE forState:UIControlStateNormal];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_HUGE];
	self.titleLabel.textColor = WHITE;
	
	self.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	self.subtitleLabel.textColor = WHITE;
	
	self.subtitleLabel.text = [self.subtitleLabel.text stringByAppendingString:self.slover.username];
	
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		self.disablingView.hidden = NO;
		self.bubbleView.hidden = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[SLVTools playSound:SLOVED_SOUND];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SLOVED_POPUP_DISMISSED
															object:nil
														  userInfo:nil];
		
		[self.navigationController popToRootViewControllerAnimated:NO];
	}];
}

- (IBAction)rightAction:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
