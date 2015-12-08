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
#import "SLVAddressBookContact.h"


@interface SLVSlovedPopupViewController ()

@end

@implementation SLVSlovedPopupViewController

- (id)initWithContact:(SLVContact *)contact andPicture:(UIImage *)picture {
	self = [super init];
	if (self) {
		self.slover = contact;
		self.pictureImage = picture;
	}
	
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
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
		
		[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Achievement"
																   action:@"Unlocked"
																	label:@"Tutorial - Sloved by team"
																	value:@1] build]];
		
		[[Amplitude instance] logEvent:@"[Achievement] Unlocked tutorial Sloved by team"];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([self.slover.username isEqualToString:PUPPY_USERNAME]) {
		self.unknownPuppyImageView = [[UIImageView alloc] initWithFrame:self.pictureImageView.frame];
		
		self.unknownPuppyImageView.image = [UIImage imageNamed:[USER_DEFAULTS objectForKey:KEY_PUPPY_PREVIOUS_PROFILE_PICTURE_PATH]];
		
		[self.view insertSubview:self.unknownPuppyImageView aboveSubview:self.pictureImageView];
	}
	
	if (self.pictureImage) {
		self.pictureImageView.image = self.pictureImage;
	} else if ([self.slover isKindOfClass:[SLVAddressBookContact class]] && ((SLVAddressBookContact *)self.slover).picture) {
		self.pictureImageView.image = ((SLVAddressBookContact *)self.slover).picture;
	} else {
		self.pictureImageView.image = [UIImage imageNamed:@"Assets/Avatar/avatar_user_big"];
	}
	
	[SLVTools playSound:SLOVED_SOUND_PATH];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
															   action:@"Sloved"
																label:@"Displayed"
																value:@1] build]];
	
	[[Amplitude instance] logEvent:@"[Popup] Sloved displayed"];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	if (self.unknownPuppyImageView) {
		self.unknownPuppyImageView.frame = self.pictureImageView.frame;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (self.unknownPuppyImageView) {
		[self.unknownPuppyImageView hideByFadingWithDuration:VERY_LONG_ANIMATION_DURATION AndCompletion:^{
			ApplicationDelegate.needToRefreshContacts = YES;
		}];
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
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:^{
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SLOVED_POPUP_DISMISSED
															object:nil
														  userInfo:nil];
		
		[ApplicationDelegate.currentNavigationController pushViewController:[[SLVContactViewController alloc] initWithContact:self.slover andPicture:self.pictureImage] animated:YES];
	}];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
															   action:@"Sloved"
																label:@"Returned"
																value:@1] build]];
	
	[[Amplitude instance] logEvent:@"[Popup] Sloved returned"];
}

- (IBAction)rightAction:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
	
	[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Popup"
															   action:@"Sloved"
																label:@"Thanked"
																value:@1] build]];
	
	[[Amplitude instance] logEvent:@"[Popup] Sloved thanked"];
}

@end
