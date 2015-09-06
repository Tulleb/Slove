//
//  SLVSloveSentViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 01/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSloveSentViewController.h"

@interface SLVSloveSentViewController ()

@end

@implementation SLVSloveSentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.logoImageView.image = [UIImage imageNamed:@"Assets/Image/notif_envoi"];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
	self.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	
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