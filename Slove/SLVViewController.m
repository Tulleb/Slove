//
//  SLVViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVViewController ()

@end

@implementation SLVViewController

- (id)init {
	self = [super init];
	if (self) {
		self.backButtonType = kBackToPrevious;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self animateImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAppName:(NSString *)appName {
	_appName = appName;
	
	if (_appName && ![_appName isEqualToString:@""]) {
		self.title = _appName;
	}
}

// Subclassed method
- (void)animateImages {
	
}

@end
