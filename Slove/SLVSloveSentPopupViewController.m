//
//  SLVSloveSentPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 01/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSloveSentPopupViewController.h"

@interface SLVSloveSentPopupViewController ()

@end

@implementation SLVSloveSentPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.view.backgroundColor = BLUE_ALPHA;
	
	self.logoImageView.image = [UIImage imageNamed:@"Assets/Image/notif_envoi"];
	self.bubbleImageView.image = [UIImage imageNamed:@"Assets/Image/infobulle_tuto_premierevisite"];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_HUGE];
	self.titleLabel.textColor = WHITE;
	
	self.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	self.subtitleLabel.textColor = WHITE;
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tap.delegate = self;
	
	[self.view addGestureRecognizer:tap];
	
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		self.bubbleView.hidden = NO;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[SLVTools playSound:SLOVER_SOUND];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.bubbleLabelTopLayoutConstraint.constant = SCREEN_HEIGHT * 0.12;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SLOVE_SENT_POPUP_DISMISSED
														object:nil
													  userInfo:nil];
	
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
