//
//  SLVConstructionPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 06/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVConstructionPopupViewController.h"

@interface SLVConstructionPopupViewController ()

@end

@implementation SLVConstructionPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = BLUE_ALPHA;
	
	self.logoImageView.image = [UIImage imageNamed:@"Assets/Image/illu_commingsoon"];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_HUGE];
	self.titleLabel.textColor = WHITE;
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tap.delegate = self;
	
	[self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
