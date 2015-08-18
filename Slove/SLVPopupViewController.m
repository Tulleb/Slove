//
//  SLVPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 16/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"

@interface SLVPopupViewController ()

@end

@implementation SLVPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.previousViewScreenshot = [[UIImageView alloc] initWithFrame:self.view.frame];
	self.previousViewScreenshot.hidden = YES;
	self.previousViewScreenshot.translatesAutoresizingMaskIntoConstraints = NO;
	
	[self.view addSubview:self.previousViewScreenshot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.view sendSubviewToBack:self.previousViewScreenshot];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeLeading
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.previousViewScreenshot
														  attribute:NSLayoutAttributeLeading
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeTrailing
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.previousViewScreenshot
														  attribute:NSLayoutAttributeTrailing
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeTop
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.previousViewScreenshot
														  attribute:NSLayoutAttributeTop
														 multiplier:1
														   constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
														  attribute:NSLayoutAttributeBottom
														  relatedBy:NSLayoutRelationEqual
															 toItem:self.previousViewScreenshot
														  attribute:NSLayoutAttributeBottom
														 multiplier:1
														   constant:0]];
}

@end
