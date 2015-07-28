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
	self.activityButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.sloveButton.translatesAutoresizingMaskIntoConstraints = NO;
	self.profileButton.translatesAutoresizingMaskIntoConstraints = NO;
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
	
	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeHeight
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:40]];
	[self.activityButton addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeWidth
																	relatedBy:NSLayoutRelationEqual
																	   toItem:nil
																	attribute:NSLayoutAttributeNotAnAttribute
																   multiplier:1
																	 constant:100]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeLeading
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeLeading
																   multiplier:1
																	 constant:8]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.activityButton
																	attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeCenterY
																   multiplier:1
																	 constant:0]];
	
	[self.sloveButton addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveButton
																 attribute:NSLayoutAttributeHeight
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1
																  constant:40]];
	[self.sloveButton addConstraint:[NSLayoutConstraint constraintWithItem:self.sloveButton
																 attribute:NSLayoutAttributeWidth
																 relatedBy:NSLayoutRelationEqual
																	toItem:nil
																 attribute:NSLayoutAttributeNotAnAttribute
																multiplier:1
																  constant:100]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	toItem:self.sloveButton
																	attribute:NSLayoutAttributeCenterY
																multiplier:1
																	 constant:0]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeCenterX
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.sloveButton
																	attribute:NSLayoutAttributeCenterX
																   multiplier:1
																	 constant:0]];
	

	[self.profileButton addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
																   attribute:NSLayoutAttributeHeight
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:40]];
	[self.profileButton addConstraint:[NSLayoutConstraint constraintWithItem:self.profileButton
																   attribute:NSLayoutAttributeWidth
																   relatedBy:NSLayoutRelationEqual
																	  toItem:nil
																   attribute:NSLayoutAttributeNotAnAttribute
																  multiplier:1
																	constant:100]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																   attribute:NSLayoutAttributeTrailing
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.profileButton
																   attribute:NSLayoutAttributeTrailing
																  multiplier:1
																	constant:8]];
	[self.bottomNavigationBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomNavigationBarView
																	attribute:NSLayoutAttributeCenterY
																	relatedBy:NSLayoutRelationEqual
																	   toItem:self.profileButton
																	attribute:NSLayoutAttributeCenterY
																   multiplier:1
																	 constant:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadBottomNavigationBar {
	self.bottomNavigationBarView = [[UIView alloc] init];
	self.activityButton = [[UIButton alloc] init];
	self.sloveButton = [[UIButton alloc] init];
	self.profileButton = [[UIButton alloc] init];
	
	self.bottomNavigationBarView.backgroundColor = VERY_LIGHT_GRAY;
	
	[self.activityButton setTitle:@"Activity" forState:UIControlStateNormal];
	[self.sloveButton setTitle:@"Slove" forState:UIControlStateNormal];
	[self.profileButton setTitle:@"Profile" forState:UIControlStateNormal];
	
	[self.activityButton setTitleColor:DARK_GRAY forState:UIControlStateNormal];
	[self.sloveButton setTitleColor:DARK_GRAY forState:UIControlStateNormal];
	[self.profileButton setTitleColor:DARK_GRAY forState:UIControlStateNormal];
	
	self.activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	self.sloveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	self.profileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[self.bottomNavigationBarView addSubview:self.activityButton];
	[self.bottomNavigationBarView addSubview:self.sloveButton];
	[self.bottomNavigationBarView addSubview:self.profileButton];
	
	[self.view addSubview:self.bottomNavigationBarView];
	
	[SLVViewController setStyle:self.bottomNavigationBarView];
}

- (IBAction)activityAction:(id)sender {
}

- (IBAction)sloveAction:(id)sender {
}

- (IBAction)profileAction:(id)sender {
}

@end
