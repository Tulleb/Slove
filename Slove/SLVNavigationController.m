//
//  SLVNavigationController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVNavigationController.h"
#import "SLVPopupViewController.h"
#import "SLVContactViewController.h"
#import "SLVActivityViewController.h"
#import "SLVConnectionViewController.h"
#import "SLVHomeViewController.h"
#import "SLVContactViewController.h"

@interface SLVNavigationController ()

@end

@implementation SLVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadLoader];
	[self loadTopNavigationBar];
	[self loadBottomNavigationBar];
	
	self.firstLoad = YES;
	
	self.tracker = [[GAI sharedInstance] defaultTracker];
	if ([PFUser currentUser]) {
		[self.tracker set:kGAIUserId value:[PFUser currentUser].username];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.firstLoad) {
		if (ApplicationDelegate.nextLoadingViewWithoutAnimation) {
			ApplicationDelegate.nextLoadingViewWithoutAnimation = NO;
			self.loaderImageView.hidden = NO;
		} else {
			[self.loaderImageView showByZoomingOutWithDuration:SHORT_ANIMATION_DURATION AndCompletion:nil];
		}
		
		self.firstLoad = NO;
	}
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeLeading
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.loaderImageView
														  attribute:NSLayoutAttributeLeading
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeTrailing
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.loaderImageView
														  attribute:NSLayoutAttributeTrailing
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.loaderImageView
														  attribute:NSLayoutAttributeBottom
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.loaderImageView
														  attribute:NSLayoutAttributeTop
														 multiplier:1
														   constant:0]];
	
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
																	 constant:67]];
	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:153]];
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
																constant:SLOVE_BUTTON_SIZE * 0.65]];
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
																	constant:67]];
	[self.profileButton addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
																   attribute:NSLayoutAttributeWidth
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:153]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([viewController isKindOfClass:[SLVContactViewController class]]) {
		[self animateSloveButton:NO];
		[self moveSloveViewTop];
	}
	
	[super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
	if (self.sloveViewIsMoved && !([self.viewControllers count] >= 2 && [[self.viewControllers objectAtIndex:[self.viewControllers count] - 2] isKindOfClass:[SLVContactViewController class]])) {
		[self animateSloveButton:YES];
		[self moveSloveViewBottom];
	}
	
	if ([self.viewControllers count] == 2 && [self.viewControllers.firstObject isKindOfClass:[SLVConnectionViewController class]]) {
		SLVConnectionViewController *rootViewController = self.viewControllers.firstObject;
		rootViewController.calledFromBackButton = YES;
	}
	
	return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
	if (self.sloveViewIsMoved) {
		[self animateSloveButton:YES];
		[self moveSloveViewBottom];
	}
	
	if ([self.viewControllers.firstObject isKindOfClass:[SLVConnectionViewController class]]) {
		SLVConnectionViewController *rootViewController = self.viewControllers.firstObject;
		rootViewController.calledFromBackButton = YES;
	}
	
	return [super popToRootViewControllerAnimated:animated];
}

- (void)homeAction:(id)sender {
	[self popToRootViewControllerAnimated:YES];
}

- (void)activityAction:(id)sender {
	if (!self.activityButton.selected) {
		SLVActivityViewController *activityViewController = [[SLVActivityViewController alloc] init];
		
		[self popToRootViewControllerAnimated:NO];
		[self pushViewController:activityViewController animated:NO];
	}
}

- (void)sloveAction:(id)sender {
	if (![self.topViewController isKindOfClass:[SLVContactViewController class]]) {
		[self homeAction:self.sloveButton];
	}
}

- (void)sloveLongPress:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {;
		[self.sloveLastClickTimer invalidate];
		self.sloveClickTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_FREQUENCY target:self selector:@selector(incrementSloveClickDuration) userInfo:nil repeats:YES];
		
		if ([self.topViewController isKindOfClass:[SLVContactViewController class]]) {
			SLVContactViewController *profileViewController = (SLVContactViewController *)self.topViewController;
			[profileViewController.circleImageView startAnimating];
			profileViewController.circleImageView.hidden = NO;
		}
	} else if (gesture.state == UIGestureRecognizerStateEnded) {
		[self.sloveClickTimer invalidate];
		self.sloveLastClickTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_FREQUENCY target:self selector:@selector(decrementDecelerationDuration) userInfo:nil repeats:YES];
		
		if ([self.topViewController isKindOfClass:[SLVContactViewController class]]) {
			SLVContactViewController *profileViewController = (SLVContactViewController *)self.topViewController;
			if (self.sloveClickDuration >= 2) {
				[profileViewController sloveAction:self.sloveButton];
			}
			
			profileViewController.circleImageView.hidden = YES;
			[profileViewController.circleImageView stopAnimating];
			
			if (!IS_IOS7) {
				[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Animation"
																		   action:@"Slove wheel"
																			label:@"Duration"
																			value:[NSNumber numberWithFloat:self.sloveClickDecelerationDuration]] build]];
				
				NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
				[eventProperties setValue:[NSNumber numberWithFloat:self.sloveClickDecelerationDuration] forKey:@"Value"];
				[[Amplitude instance] logEvent:@"[Animation] Slove wheel duration" withEventProperties:eventProperties];
			}
		} else {
			[self homeAction:self.sloveButton];
		}
		
		self.sloveClickDuration = 0;
	}
}

- (void)profileAction:(id)sender {
	if (!self.profileButton.selected) {
		SLVProfileViewController *parametersViewController = [[SLVProfileViewController alloc] init];
		
		[self popToRootViewControllerAnimated:NO];
		[self pushViewController:parametersViewController animated:NO];
	}
}

- (void)goToHome {
	[self homeAction:nil];
}

- (void)loadLoader {
	self.loaderImageView = [[UIImageView alloc] init];
	
	self.loaderImageView.contentMode = UIViewContentModeScaleAspectFill;
	
	NSMutableArray *animatedImages = [[NSMutableArray alloc] init];
	NSString *prefixImageName = @"Assets/Animation/Loading/anim_loading";
	
	for (int i = 1; i <= 14; i++) {
		[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%d", i]]] atIndex:i - 1];
	}
	
	self.loaderImageView.animationImages = animatedImages;
	self.loaderImageView.animationDuration = 1;
	self.loaderImageView.animationRepeatCount = 0;
	self.loaderImageView.hidden = YES;
	[self.loaderImageView startAnimating];
	
	[self.view addSubview:self.loaderImageView];
	
	self.loaderImageView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)loadTopNavigationBar {
//	NSShadow* shadow = [NSShadow new];
//	shadow.shadowOffset = CGSizeMake(0, 1);
//	shadow.shadowColor = CLEAR;
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSFontAttributeName:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE], NSForegroundColorAttributeName:DEFAULT_TEXT_COLOR}];
	[[UINavigationBar appearance] setBarTintColor:WHITE];
	if (!IS_IOS7) {
		[[UINavigationBar appearance] setTranslucent:NO];
		[[UINavigationBar appearance] setBackgroundImage:[UIImage new]
										  forBarPosition:UIBarPositionAny
											  barMetrics:UIBarMetricsDefault];
		
		[[UINavigationBar appearance] setShadowImage:[UIImage new]];
	}
}

- (void)incrementSloveClickDuration {
	// There is a maximum duration to avoid the animated wheel to turn reversed
	if (self.sloveClickDuration <= 6.2) {
		self.sloveClickDuration += TIMER_FREQUENCY;
		self.sloveClickDecelerationDuration = self.sloveClickDuration;
	}
}

- (void)decrementDecelerationDuration {
	self.sloveClickDecelerationDuration -= TIMER_FREQUENCY;
	
	if (self.sloveClickDecelerationDuration <= 0) {
		[self.sloveLastClickTimer invalidate];
	}
}

- (void)loadBottomNavigationBar {
	self.bottomNavigationBarView = [[UIView alloc] init];
	self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.sloveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.profileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.sloveView = [[UIView alloc] init];
	self.sloveCounterBadge = [CustomBadge customBadgeWithString:@"" withStyle:[BadgeStyle freeStyleWithTextColor:RED withInsetColor:WHITE withFrameColor:RED withFrame:YES withShadow:NO withShining:NO withFontType:BadgeStyleFontTypeHelveticaNeueMedium]];
	
	self.bottomNavigationBarView.backgroundColor = CLEAR;
	
	[self.homeButton setImage:[UIImage imageNamed:@"Assets/Button/logo_txt"] forState:UIControlStateNormal];
	[self.homeButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.activityButton setTitle:@"button_activity" forState:UIControlStateNormal];
	[self.activityButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.activityButton setTitleColor:BLUE forState:UIControlStateHighlighted];
	[self.activityButton setTitleColor:BLUE forState:UIControlStateSelected];
	[self.activityButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
//	self.activityButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
	[self.activityButton setTitleEdgeInsets:UIEdgeInsetsMake(40, -10, 0, 25)];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity"] forState:UIControlStateNormal];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateHighlighted];
	[self.activityButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateSelected];
	[self.activityButton setImageEdgeInsets:UIEdgeInsetsMake(5, 25, 0, 0)];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity"] forState:UIControlStateNormal];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateHighlighted];
	[self.activityButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateSelected];
	self.activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.activityButton addTarget:self action:@selector(activityAction:) forControlEvents:UIControlEventTouchUpInside];
	
	self.sloveView.backgroundColor = CLEAR;
	
	self.sloveButton.imageView.contentMode = UIViewContentModeScaleToFill;
	[self.sloveButton setImage:[UIImage imageNamed:@"Assets/Button/logo_slove_menu"] forState:UIControlStateNormal];
	[self.sloveButton addTarget:self action:@selector(sloveAction:) forControlEvents:UIControlEventTouchUpInside];
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sloveLongPress:)];
	[self.sloveButton addGestureRecognizer:longPress];
	self.sloveButton.imageView.animationDuration = LONG_ANIMATION_DURATION;
	self.sloveButton.imageView.animationRepeatCount = 1;
	
	[self loadSloveButtonAnimation:NO];
	
	[self.profileButton setTitle:@"button_profile" forState:UIControlStateNormal];
	[self.profileButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.profileButton setTitleColor:BLUE forState:UIControlStateHighlighted];
	[self.profileButton setTitleColor:BLUE forState:UIControlStateSelected];
	[self.profileButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
//	self.profileButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);
	[self.profileButton setTitleEdgeInsets:UIEdgeInsetsMake(40, 40, 0, 5)];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile"] forState:UIControlStateNormal];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateHighlighted];
	[self.profileButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateSelected];
	[self.profileButton setImageEdgeInsets:UIEdgeInsetsMake(8, 112, 0, 0)];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile"] forState:UIControlStateNormal];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateHighlighted];
	[self.profileButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateSelected];
	self.profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	[self.profileButton addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.bottomNavigationBarView addSubview:self.activityButton];
	[self.bottomNavigationBarView addSubview:self.profileButton];
	
	[self.view addSubview:self.bottomNavigationBarView];
	[self.view addSubview:self.homeButton];
	[self.view addSubview:self.sloveView];
	[self.sloveView addSubview:self.sloveButton];
	[self.sloveView addSubview:self.sloveCounterBadge];
	
	[SLVViewController setStyle:self.view];
	
	[self.activityButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_SMALL]];
	[self.profileButton.titleLabel setFont:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_SMALL]];
	
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
															multiplier:1
															  constant:SLOVE_BUTTON_SIZE];
}

- (void)loadSloveButtonAnimation:(BOOL)reversed {
	NSMutableArray *animatedImages = [[NSMutableArray alloc] init];
	NSString *prefixImageName = @"Assets/Animation/Morphin_Slovy/morphing_Slove_fixe00";
	
	if (reversed) {
		for (int i = 25; i >= 1; i--) {
			if (i < 10) {
				[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"0%d", i]]] atIndex:25 - i];
			} else {
				[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%d", i]]] atIndex:25 - i];
			}
		}
	} else {
		for (int i = 1; i <= 25; i++) {
			if (i < 10) {
				[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"0%d", i]]] atIndex:i - 1];
			} else {
				[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%d", i]]] atIndex:i - 1];
			}
		}
	}
	
	self.sloveButton.imageView.animationImages = animatedImages;
}

- (void)animateSloveButton:(BOOL)reversed {
	[self loadSloveButtonAnimation:reversed];
	
	if (reversed) {
		[self.sloveButton setImage:[UIImage imageNamed:@"Assets/Button/logo_slove_menu"] forState:UIControlStateNormal];
	} else {
		[self.sloveButton setImage:[UIImage imageNamed:@"Assets/Button/logo_slove_spirale"] forState:UIControlStateNormal];
	}
	
	[self.sloveButton.imageView startAnimating];
}

- (void)moveSloveViewTop {
	[self.view removeConstraint:self.sloveViewConstraint];
	self.sloveViewConstraint = [NSLayoutConstraint constraintWithItem:self.view
															  attribute:NSLayoutAttributeCenterY
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.sloveView
															  attribute:NSLayoutAttributeCenterY
															 multiplier:1
															   constant:-(self.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height)];
	
	[UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self.view layoutIfNeeded];
	} completion:nil];
	
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
															   constant:SLOVE_VIEW_BOTTOM_CONSTANT];
	
	[UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self.view layoutIfNeeded];
	} completion:nil];
	
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
			NSNumber *sloveCount = object[@"sloveNumber"];
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
																	  constant:SLOVE_BUTTON_SIZE * (0.75 - (0.1 * [sloveCountString length]))];
			
			
			[self.sloveView setNeedsUpdateConstraints];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

@end
