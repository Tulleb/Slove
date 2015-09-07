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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[SLVViewController setStyle:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
	// To substract the navigation bar height from the view
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)] && !self.navigationController.navigationBarHidden) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	[super viewWillAppear:animated];
	
	[self animateImages];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAppName:(NSString *)appName {
	_appName = [NSString stringWithFormat:@"title_%@", appName];
	
	if (_appName && ![_appName isEqualToString:@""]) {
		self.title = NSLocalizedString(_appName, nil);
	}
}

+ (void)setStyle:(UIView *)view {
	for (UIView *subview in view.subviews) {
		if (subview.tag >= 0) {
			if ([subview isKindOfClass:[UILabel class]]) {
				UILabel *label = (UILabel *)subview;
				
				label.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
				label.text = NSLocalizedString(label.text, nil);
				label.adjustsFontSizeToFitWidth = YES;
			} else if ([subview isKindOfClass:[UIButton class]]) {
				UIButton *button = (UIButton *)subview;
				
				button.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
				[button setTitle:NSLocalizedString(button.titleLabel.text, nil) forState:UIControlStateNormal];
				button.titleLabel.adjustsFontSizeToFitWidth = YES;
			} else if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *textField = (UITextField *)subview;
				
				textField.text = NSLocalizedString(textField.text, nil);
				textField.placeholder = NSLocalizedString(textField.placeholder, nil);
			} else if ([subview isKindOfClass:[UITextView class]]) {
				UITextView *textView = (UITextView *)subview;
				
				textView.text = NSLocalizedString(textView.text, nil);
			} else if ([subview isKindOfClass:[UISegmentedControl class]]) {
				UISegmentedControl *segmentedControl = (UISegmentedControl *)subview;
				UIFont *font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
				NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, nil];
				[segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
				
				for (int i = 0; i < segmentedControl.numberOfSegments; i++) {
					[segmentedControl setTitle:NSLocalizedString([segmentedControl titleForSegmentAtIndex:i], nil) forSegmentAtIndex:i];
				}
			}
			
			[self setStyle:subview];
		}
	}
}

// Subclassed method
- (void)animateImages {
	
}

- (void)loadBackButton {
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
	[backButton setTitle:NSLocalizedString(@"Return", nil) forState:UIControlStateNormal];
	[backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
	[backButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
	[backButton setTitleColor:DARK_GRAY forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
	backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	[backButton setImage:[UIImage imageNamed:@"Assets/Button/fleche_retour"] forState:UIControlStateNormal];
	[backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)goBack:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)goToHome {
	[ApplicationDelegate.currentNavigationController goToHome];
}

@end
