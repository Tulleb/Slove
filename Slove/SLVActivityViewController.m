//
//  SLVActivityViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 07/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVActivityViewController.h"
#import "SLVConstructionPopupViewController.h"

@interface SLVActivityViewController ()

@end

@implementation SLVActivityViewController

- (void)viewDidLoad {
	self.appName = @"activity";
	
    [super viewDidLoad];
	
	[self loadBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	SLVConstructionPopupViewController *constructionPopup = [[SLVConstructionPopupViewController alloc] init];
	
	[self.navigationController presentViewController:constructionPopup animated:YES completion:nil];
}

- (void)goBack:(id)sender {
	[super goToHome];
}

@end
