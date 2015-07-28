//
//  SLVNavigationController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVNavigationController.h"

@interface SLVNavigationController ()

@end

@implementation SLVNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self loadBottomNavigationBar];
	self.bottomNavigationBarView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
														  attribute:NSLayoutAttributeLeading
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.view
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
	
//	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:51]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//	[super pushViewController:viewController animated:animated];
//	
//	self.bottomNavigationBarView.hidden = !ApplicationDelegate.userIsConnected;
//}
//
//- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
//	NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
//	
//	self.bottomNavigationBarView.hidden = !ApplicationDelegate.userIsConnected;
//	
//	return viewControllers;
//}
//
//- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
//	NSArray *viewControllers = [super popToViewController:viewController animated:animated];
//	
//	self.bottomNavigationBarView.hidden = !ApplicationDelegate.userIsConnected;
//	
//	return viewControllers;
//}
//
//- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
//	UIViewController *viewController = [super popViewControllerAnimated:animated];
//	
//	self.bottomNavigationBarView.hidden = !ApplicationDelegate.userIsConnected;
//	
//	return viewController;
//}

- (void)loadBottomNavigationBar {
	self.bottomNavigationBarView = [[UIView alloc] init];
	self.activityButton = [[UIButton alloc] init];
	self.sloveButton = [[UIButton alloc] init];
	self.profileButton = [[UIButton alloc] init];
	
	self.bottomNavigationBarView.backgroundColor = VERY_LIGHT_GRAY;
	
//	[self.bottomNavigationBarView addSubview:self.activityButton];
//	[self.bottomNavigationBarView addSubview:self.sloveButton];
//	[self.bottomNavigationBarView addSubview:self.profileButton];
	
	[self.view addSubview:self.bottomNavigationBarView];
}

- (IBAction)activityAction:(id)sender {
}

- (IBAction)sloveAction:(id)sender {
}

- (IBAction)profileAction:(id)sender {
}

@end
