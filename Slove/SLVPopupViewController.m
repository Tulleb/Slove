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

- (id)init {
	self = [super init];
	if (self) {
		self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

@end
