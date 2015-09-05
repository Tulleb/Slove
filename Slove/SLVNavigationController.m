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
	
	[self.statisticsButton addConstraint:[NSLayoutConstraint constraintWithItem:self.statisticsButton
																	attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:60]];
	[self.statisticsButton addConstraint:[NSLayoutConstraint constraintWithItem:self.statisticsButton
																	attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:168]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.statisticsButton
																	attribute:NSLayoutAttributeLeading
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeLeading
																   multiplier:1
																	 constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.statisticsButton
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

	[self.parametersButton addConstraint:[NSLayoutConstraint constraintWithItem:self.parametersButton
																   attribute:NSLayoutAttributeHeight
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:60]];
	[self.parametersButton addConstraint:[NSLayoutConstraint constraintWithItem:self.parametersButton
																   attribute:NSLayoutAttributeWidth
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:168]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																   attribute:NSLayoutAttributeTrailing
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.parametersButton
																   attribute:NSLayoutAttributeTrailing
																  multiplier:1
																	constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeBottom
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.parametersButton
																	attribute:NSLayoutAttributeBottom
																   multiplier:1
																	 constant:0]];
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
	self.statisticsButton.selected = NO;
	self.parametersButton.selected = NO;
	
	[self popToRootViewControllerAnimated:YES];
}

- (void)statisticsAction:(id)sender {
	if (!self.statisticsButton.selected) {
		self.statisticsButton.selected = YES;
		self.parametersButton.selected = NO;
	}
}

- (void)sloveAction:(id)sender {
	if (![self.topViewController isKindOfClass:[SLVProfileViewController class]]) {
		[self homeAction:self.sloveButton];
	}
}

- (void)sloveLongPress:(UILongPressGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateBegan) {;
		self.sloveClickTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_FREQUENCY target:self selector:@selector(incrementSloveClickDuration) userInfo:nil repeats:YES];
		
		if ([self.topViewController isKindOfClass:[SLVProfileViewController class]]) {
			SLVProfileViewController *profileViewController = (SLVProfileViewController *)self.topViewController;
			[profileViewController.circleImageView startAnimating];
			profileViewController.circleImageView.hidden = NO;
		}
	} else if (gesture.state == UIGestureRecognizerStateEnded) {
		[self.sloveClickTimer invalidate];
		
		if ([self.topViewController isKindOfClass:[SLVProfileViewController class]]) {
			SLVProfileViewController *profileViewController = (SLVProfileViewController *)self.topViewController;
			if (self.sloveClickDuration >= 2) {
				[profileViewController sloveAction:self.sloveButton];
			}
			
			profileViewController.circleImageView.hidden = YES;
			[profileViewController.circleImageView stopAnimating];
		} else {
			[self homeAction:self.sloveButton];
		}
		
		self.sloveClickDuration = 0;
	}
}

- (void)parametersAction:(id)sender {
	if (!self.parametersButton.selected) {
		self.statisticsButton.selected = NO;
		self.parametersButton.selected = YES;
		
		SLVParametersViewController *parametersViewController = [[SLVParametersViewController alloc] init];
		
		[self popToRootViewControllerAnimated:NO];
		[self pushViewController:parametersViewController animated:YES];
	}
}

- (void)goToHome {
	[self homeAction:nil];
}

- (void)loadTopNavigationBar {
//	NSShadow* shadow = [NSShadow new];
//	shadow.shadowOffset = CGSizeMake(0, 1);
//	shadow.shadowColor = CLEAR;
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:DARK_GRAY,
															NSFontAttributeName:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE]}];
	[[UINavigationBar appearance] setBarTintColor:SUB_COLOR];
	if (!IS_IOS7) {
		[[UINavigationBar appearance] setTranslucent:NO];
		[[UINavigationBar appearance] setBackgroundImage:[UIImage new]
										  forBarPosition:UIBarPositionAny
											  barMetrics:UIBarMetricsDefault];
		
		[[UINavigationBar appearance] setShadowImage:[UIImage new]];
	}
}

- (void)incrementSloveClickDuration {
	self.sloveClickDuration += TIMER_FREQUENCY;
}

- (void)loadBottomNavigationBar {
	self.bottomNavigationBarView = [[UIView alloc] init];
	self.homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.statisticsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.sloveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.parametersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.sloveView = [[UIView alloc] init];
	self.sloveCounterBadge = [CustomBadge customBadgeWithString:@"" withStyle:[BadgeStyle freeStyleWithTextColor:WHITE withInsetColor:RED withFrameColor:WHITE withFrame:YES withShadow:YES withShining:YES withFontType:BadgeStyleFontTypeHelveticaNeueMedium]];
	
	self.bottomNavigationBarView.backgroundColor = CLEAR;
	
	[self.homeButton setImage:[UIImage imageNamed:@"Assets/Button/logo_txt"] forState:UIControlStateNormal];
	[self.homeButton setTitleColor:DARK_GRAY forState:UIControlStateNormal];
	self.homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	[self.homeButton addTarget:self action:@selector(homeAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.statisticsButton setTitle:@"button_activity" forState:UIControlStateNormal];
	[self.statisticsButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.statisticsButton setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
	[self.statisticsButton setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
	[self.statisticsButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
//	self.statisticsButton.titleLabel.shadowOffset = CGSizeMake(1, 1);
	[self.statisticsButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 15, 0, 25)];
	[self.statisticsButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity"] forState:UIControlStateNormal];
	[self.statisticsButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateHighlighted];
	[self.statisticsButton setImage:[UIImage imageNamed:@"Assets/Button/picto_activity_clic"] forState:UIControlStateSelected];
	[self.statisticsButton setImageEdgeInsets:UIEdgeInsetsMake(20, 10, 0, 0)];
	[self.statisticsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity"] forState:UIControlStateNormal];
	[self.statisticsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateHighlighted];
	[self.statisticsButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_activity_clic"] forState:UIControlStateSelected];
	self.statisticsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.statisticsButton addTarget:self action:@selector(statisticsAction:) forControlEvents:UIControlEventTouchUpInside];
	
	self.sloveView.backgroundColor = CLEAR;
	
	self.sloveButton.imageView.contentMode = UIViewContentModeScaleToFill;
	[self.sloveButton setImage:[UIImage imageNamed:@"Assets/Button/bt_slove_slovy_big"] forState:UIControlStateNormal];
	[self.sloveButton addTarget:self action:@selector(sloveAction:) forControlEvents:UIControlEventTouchUpInside];
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sloveLongPress:)];
	[self.sloveButton addGestureRecognizer:longPress];
	
	[self.parametersButton setTitle:@"button_profile" forState:UIControlStateNormal];
	[self.parametersButton setTitleColor:WHITE forState:UIControlStateNormal];
	[self.parametersButton setTitleColor:MAIN_COLOR forState:UIControlStateHighlighted];
	[self.parametersButton setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
	[self.parametersButton setTitleShadowColor:DARK_GRAY forState:UIControlStateNormal];
//	self.parametersButton.titleLabel.shadowOffset = CGSizeMake(-1, 1);
	[self.parametersButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 90, 0, 0)];
	[self.parametersButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile"] forState:UIControlStateNormal];
	[self.parametersButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateHighlighted];
	[self.parametersButton setImage:[UIImage imageNamed:@"Assets/Button/picto_profile_clic"] forState:UIControlStateSelected];
	[self.parametersButton setImageEdgeInsets:UIEdgeInsetsMake(20, 85, 0, 15)];
	[self.parametersButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile"] forState:UIControlStateNormal];
	[self.parametersButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateHighlighted];
	[self.parametersButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_profile_clic"] forState:UIControlStateSelected];
	self.parametersButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[self.parametersButton addTarget:self action:@selector(parametersAction:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.bottomNavigationBarView addSubview:self.statisticsButton];
	[self.bottomNavigationBarView addSubview:self.parametersButton];
	
	[self.view addSubview:self.bottomNavigationBarView];
	[self.view addSubview:self.homeButton];
	[self.view addSubview:self.sloveView];
	[self.sloveView addSubview:self.sloveButton];
	[self.sloveView addSubview:self.sloveCounterBadge];
	
	[SLVViewController setStyle:self.view];
	
	self.bottomNavigationBarView.translatesAutoresizingMaskIntoConstraints = NO;
	self.homeButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.statisticsButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveView.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveCounterBadge.translatesAutoresizingMaskIntoConstraints = NO;
	self.parametersButton.translatesAutoresizingMaskIntoConstraints = NO;
	
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
															   constant:15];
	
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
