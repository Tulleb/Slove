//
//  SLVNavigationController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVNavigationController.h"
#import "SLVPopupViewController.h"
#import "SLVProfileViewController.h"

@interface SLVNavigationController ()

@end

@implementation SLVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadTopNavigationBar];
	[self loadBottomNavigationBar];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeLeading
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.bottomNavigationBarView
														  attribute:NSLayoutAttributeLeading
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeTrailing
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.bottomNavigationBarView
														  attribute:NSLayoutAttributeTrailing
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.bottomNavigationBarView
														  attribute:NSLayoutAttributeBottom
														 multiplier:1
														   constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																			 attribute:NSLayoutAttributeHeight
																			 relatedBy:NSLayoutRelationEqual
																				toItem:nil
																			 attribute:NSLayoutAttributeNotAnAttribute
																			multiplier:1
																			  constant:70]];
	
	[self.homeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.homeButton
																attribute:NSLayoutAttributeHeight
																relatedBy:NSLayoutRelationEqual
																   toItem:nil
																attribute:NSLayoutAttributeNotAnAttribute
															   multiplier:1
																 constant:SLOVE_BUTTON_SIZE]];
	[self.homeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.homeButton
																attribute:NSLayoutAttributeWidth
																relatedBy:NSLayoutRelationEqual
																   toItem:nil
																attribute:NSLayoutAttributeNotAnAttribute
															   multiplier:1
																 constant:SLOVE_BUTTON_SIZE]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.homeButton
														  attribute:NSLayoutAttributeBottom
														 multiplier:1
														   constant:SLOVE_VIEW_BOTTOM_CONSTANT]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeCenterX
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.homeButton
														  attribute:NSLayoutAttributeCenterX
														 multiplier:1
														   constant:0]];
	
	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:51]];
	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:147]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeLeading
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeLeading
																   multiplier:1
																	 constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeBottom
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeBottom
																   multiplier:1
																	 constant:0]];
	
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
																 attribute:NSLayoutAttributeHeight
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1
																  constant:SLOVE_BUTTON_SIZE]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
																 attribute:NSLayoutAttributeWidth
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1
																  constant:SLOVE_BUTTON_SIZE]];
	[self.view addConstraint:self.sloveViewConstraint];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
																			 attribute:NSLayoutAttributeCenterX
																			 relatedBy:NSLayoutRelationEqual
																	   toItem:self.sloveView
																			 attribute:NSLayoutAttributeCenterX
																   multiplier:1
																			  constant:0]];
	
	
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
														  attribute:NSLayoutAttributeLeading
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.sloveButton
														  attribute:NSLayoutAttributeLeading
														 multiplier:1
														   constant:0]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
														  attribute:NSLayoutAttributeTrailing
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.sloveButton
														  attribute:NSLayoutAttributeTrailing
														 multiplier:1
														   constant:0]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.sloveButton
														  attribute:NSLayoutAttributeBottom
														 multiplier:1
														   constant:0]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.sloveButton
														  attribute:NSLayoutAttributeTop
														 multiplier:1
														   constant:0]];
	
	[self.sloveView addConstraint:self.sloveBadgeConstraint];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
															   attribute:NSLayoutAttributeTrailing
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.sloveCounterBadge
															   attribute:NSLayoutAttributeTrailing
															  multiplier:1
																constant:SLOVE_BUTTON_SIZE * 0.05]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveView
															   attribute:NSLayoutAttributeBottom
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.sloveCounterBadge
															   attribute:NSLayoutAttributeBottom
															  multiplier:1
																constant:SLOVE_BUTTON_SIZE * 0.6]];
	[self.sloveView addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveCounterBadge
															   attribute:NSLayoutAttributeTop
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.sloveView
															   attribute:NSLayoutAttributeTop
															  multiplier:1
																constant:SLOVE_BUTTON_SIZE * 0.05]];

	[self.profileButton addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
																   attribute:NSLayoutAttributeHeight
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:51]];
	[self.profileButton addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
																   attribute:NSLayoutAttributeWidth
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:147]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																   attribute:NSLayoutAttributeTrailing
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.profileButton
																   attribute:NSLayoutAttributeTrailing
																  multiplier:1
																	constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeBottom
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.profileButton
																	attribute:NSLayoutAttributeBottom
																   multiplier:1
																	 constant:0]];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
	if ([viewControllerToPresent isKindOfClass:[SLVPopupViewController class]]) {
		SLVPopupViewController *popupViewController = (SLVPopupViewController *)viewControllerToPresent;
		
		UIView *currentView = self.view;
		UIGraphicsBeginImageContextWithOptions(currentView.bounds.size, currentView.opaque, 0.0);
		[currentView.layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		[super presentViewController:viewControllerToPresent animated:flag completion:^{
			popupViewController.previousViewScreenshot.image = img;
			popupViewController.previousViewScreenshot.hidden = NO;
			
			if (completion) {
				completion();
			}
		}];
	} else {
		[super presentViewController:viewControllerToPresent animated:flag completion:completion];
	}
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
	if ([self.presentedViewController isKindOfClass:[SLVPopupViewController class]]) {
		SLVPopupViewController *popupViewController = (SLVPopupViewController *)self.presentedViewController;
		
		popupViewController.previousViewScreenshot.hidden = YES;
		popupViewController.previousViewScreenshot.image = nil;
	}
	
	[super dismissViewControllerAnimated:flag completion:completion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[SLVProfileViewController class]]) {
		[self moveSloveViewTop];
	}
	
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	if (self.sloveViewIsMoved) {
		[self moveSloveViewBottom];
	}
	
	return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	if (self.sloveViewIsMoved) {
		[self moveSloveViewBottom];
	}
	
	return [super popToRootViewControllerAnimated:animated];
}

- (void)homeAction:(id)sender {
	[self popToRootViewControllerAnimated:YES];
}

- (void)activityAction:(id)sender {
	self.activityButton.selected = YES;
	self.profileButton.selected = NO;
}

- (void)sloveAction:(id)sender {
	if ([self.topViewController isKindOfClass:[SLVProfileViewController class]]) {
		SLVProfileViewController *profileViewController = (SLVProfileViewController *)self.topViewController;
		[profileViewController sloveAction:sender];
	} else {
		self.activityButton.selected = NO;
		self.profileButton.selected = NO;
	}
}

- (void)profileAction:(id)sender {
	self.activityButton.selected = NO;
	self.profileButton.selected = YES;
}

- (void)loadTopNavigationBar {
	NSShadow* shadow = [NSShadow new];
	shadow.shadowOffset = CGSizeMake(0, 1);
	shadow.shadowColor = CLEAR;
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:DARK_GRAY,
															NSFontAttributeName:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE],
															NSShadowAttributeName:shadow}];
}

- (void)loadBottomNavigationBar {
	self.bottomNavigationBarView = [[UIView alloc] init];
	self.homeButton = [[UIButton alloc] init];
	self.activityButton = [[UIButton alloc] init];
	self.sloveView = [[UIView alloc] init];
	self.sloveButton = [[UIButton alloc] init];
	self.sloveCounterBadge = [CustomBadge customBadgeWithString:@"" withStyle:[BadgeStyle freeStyleWithTextColor:WHITE withInsetColor:RED withFrameColor:WHITE withFrame:YES withShadow:YES withShining:YES withFontType:BadgeStyleFontTypeHelveticaNeueMedium]];
	self.profileButton = [[UIButton alloc] init];
	
	self.bottomNavigationBarView.backgroundColor = CLEAR;
	
	[self.homeButton setImage:[UIImage imageNamed:@"Assets/Button/logo_txt"] forState:UIControlStateNormal];
	[self.homeButton setTitleColor:DARK_GRAY forState:UIControlStateNormal];
	self.homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[self.homeButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.activityButton setTitle:@"button_activity" forState:UIControlStateNormal];
	[self.activityButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.activityButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
	self.activityButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
	[self.activityButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 25)];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity"] forState:UIControlStateNormal];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateHighlighted];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateSelected];
	[self.activityButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity"] forState:UIControlStateNormal];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateHighlighted];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateSelected];
	self.activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.activityButton addTarget:self action:@selector(activityAction:) forControlEvents:UIControlEventTouchUpInside];
	
	self.sloveView.backgroundColor = CLEAR;
	
	self.sloveButton.imageView.contentMode = UIViewContentModeScaleToFill;
	[self.sloveButton setImage:[UIImage imageNamed:@"Assets/Button/bt_slove_slovy_big"] forState:UIControlStateNormal];
	[self.sloveButton addTarget:self action:@selector(sloveAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.profileButton setTitle:@"button_profile" forState:UIControlStateNormal];
	[self.profileButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.profileButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
	self.profileButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);
	[self.profileButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile"] forState:UIControlStateNormal];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateHighlighted];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateSelected];
	[self.profileButton setImageEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 15)];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile"] forState:UIControlStateNormal];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateHighlighted];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateSelected];
	self.profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.profileButton addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.bottomNavigationBarView addSubview:self.activityButton];
	[self.bottomNavigationBarView addSubview:self.profileButton];
	
	[self.view addSubview:self.bottomNavigationBarView];
	[self.view addSubview:self.homeButton];
	[self.view addSubview:self.sloveView];
	[self.sloveView addSubview:self.sloveButton];
	[self.sloveView addSubview:self.sloveCounterBadge];
	
	[SLVViewController setStyle:self.view];
	
	self.bottomNavigationBarView.translatesAutoresizingMaskIntoConstraints = NO;
	self.homeButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.activityButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveView.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveCounterBadge.translatesAutoresizingMaskIntoConstraints = NO;
	self.profileButton.translatesAutoresizingMaskIntoConstraints = NO;
	
	self.sloveViewConstraint = [NSLayoutConstraint constraintWithItem:self.view
															attribute:NSLayoutAttributeBottom
															relatedBy:NSLayoutRelationEqual
															   toItem:self.sloveView
															attribute:NSLayoutAttributeBottom
														   multiplier:1
															 constant:SLOVE_VIEW_BOTTOM_CONSTANT];
	self.sloveBadgeConstraint = [NSLayoutConstraint constraintWithItem:self.sloveCounterBadge
															 attribute:NSLayoutAttributeLeading
															 relatedBy:NSLayoutRelationEqual
																toItem:self.sloveView
															 attribute:NSLayoutAttributeLeading
															multiplier:1															  constant:SLOVE_BUTTON_SIZE * 0.7];
}

- (void)moveSloveViewTop {
	[self.view removeConstraint:self.sloveViewConstraint];
	self.sloveViewConstraint = [NSLayoutConstraint constraintWithItem:self.view
															  attribute:NSLayoutAttributeCenterY
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.sloveView
															  attribute:NSLayoutAttributeCenterY
															 multiplier:1
															   constant:0];
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		[self.view layoutIfNeeded];
	}];
	
	self.sloveViewIsMoved = YES;
}

- (void)moveSloveViewBottom {
	[self.view removeConstraint:self.sloveViewConstraint];
	self.sloveViewConstraint = [NSLayoutConstraint constraintWithItem:self.view
															  attribute:NSLayoutAttributeBottom
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.sloveView
															  attribute:NSLayoutAttributeBottom
															 multiplier:1
															   constant:15];
	
	[UIView animateWithDuration:ANIMATION_DURATION animations:^{
		[self.view layoutIfNeeded];
	}];
	
	self.sloveViewIsMoved = NO;
}

- (void)hideBottomNavigationBar {
	self.bottomNavigationBarView.hidden = YES;
	self.sloveView.hidden = YES;
	self.homeButton.hidden = YES;
}

- (void)showBottomNavigationBar {
	[self refreshSloveCounter];
	self.bottomNavigationBarView.hidden = NO;
	self.sloveView.hidden = NO;
	self.homeButton.hidden = NO;
}

- (void)refreshSloveCounter {
	[[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object,  NSError *error) {
		if (!error) {
			NSNumber *sloveCount = object[@"sloveCounter"];
			NSString *sloveCountString = [NSString stringWithFormat:@"%d", [sloveCount intValue]];
			self.sloveCounterBadge.badgeText = sloveCountString;
			[self.sloveCounterBadge setNeedsDisplay];
			[self.sloveView removeConstraint:self.sloveBadgeConstraint];
			self.sloveBadgeConstraint = [NSLayoutConstraint constraintWithItem:self.sloveCounterBadge
																	 attribute:NSLayoutAttributeLeading
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.sloveView
																	 attribute:NSLayoutAttributeLeading
																	multiplier:1
																	  constant:SLOVE_BUTTON_SIZE * (0.7 - (0.1 * [sloveCountString length]))];
			
			
			[self.sloveView setNeedsUpdateConstraints];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

@end
