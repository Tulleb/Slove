//
//  SLVViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

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
	
	self.tracker = [[GAI sharedInstance] defaultTracker];
	if ([PFUser currentUser]) {
		[self.tracker set:kGAIUserId value:[PFUser currentUser].username];
	}
	[self.tracker set:kGAIScreenName value:NSStringFromClass(self.class)];
	[self.tracker send:[[GAIDictionaryBuilder createScreenView] build]];
	
	[[Amplitude instance] logEvent:[NSString stringWithFormat:@"[View] %@", NSStringFromClass(self.class)]];
	
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
				label.textColor = DEFAULT_TEXT_COLOR;
			} else if ([subview isKindOfClass:[UIButton class]]) {
				UIButton *button = (UIButton *)subview;
				
				button.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
				[button setTitle:NSLocalizedString(button.titleLabel.text, nil) forState:UIControlStateNormal];
				button.titleLabel.adjustsFontSizeToFitWidth = YES;
				button.titleLabel.textColor = DEFAULT_TEXT_COLOR;
			} else if ([subview isKindOfClass:[UITextField class]]) {
				UITextField *textField = (UITextField *)subview;
				
				textField.text = NSLocalizedString(textField.text, nil);
				textField.textColor = DEFAULT_TEXT_COLOR;
				textField.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
				
				if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
					textField.attributedPlaceholder = [[NSAttributedString alloc]
															initWithString:NSLocalizedString(textField.placeholder, nil)
															attributes:@{
																		 NSForegroundColorAttributeName:LIGHT_GRAY,
																		 NSFontAttributeName:[UIFont fontWithName:DEFAULT_FONT_ITALIC size:DEFAULT_FONT_SIZE],
																		 NSBaselineOffsetAttributeName:[NSNumber numberWithFloat:0]
																		 }];
				}
			} else if ([subview isKindOfClass:[UITextView class]]) {
				UITextView *textView = (UITextView *)subview;
				
				textView.text = NSLocalizedString(textView.text, nil);
				textView.textColor = DEFAULT_TEXT_COLOR;
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
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	[backButton setTitle:NSLocalizedString(@"button_back", nil) forState:UIControlStateNormal];
	[backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
	[backButton setTitleColor:BLUE forState:UIControlStateNormal];
	[backButton setTitleColor:DARK_GRAY forState:UIControlStateHighlighted];
	backButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
	backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	[backButton setImage:[UIImage imageNamed:@"Assets/Button/fleche_retour"] forState:UIControlStateNormal];
	[backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	[backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
	backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)loadLogoutButton {
	UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
	[logoutButton setTitle:NSLocalizedString(@"button_disconnect", nil) forState:UIControlStateNormal];
	[logoutButton setTitleColor:BLUE forState:UIControlStateNormal];
	[logoutButton setTitleColor:DARK_GRAY forState:UIControlStateHighlighted];
	logoutButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
	logoutButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	[logoutButton setImage:[UIImage imageNamed:@"Assets/Button/logout"] forState:UIControlStateNormal];
	[logoutButton addTarget:self action:@selector(disconnectAction:) forControlEvents:UIControlEventTouchUpInside];
	logoutButton.titleEdgeInsets = UIEdgeInsetsMake(0, -logoutButton.imageView.frame.size.width, 0, logoutButton.imageView.frame.size.width);
	logoutButton.imageEdgeInsets = UIEdgeInsetsMake(5, logoutButton.titleLabel.frame.size.width, 0, -logoutButton.titleLabel.frame.size.width);
	UIBarButtonItem *logoutButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
	self.navigationItem.rightBarButtonItem = logoutButtonItem;
}

- (void)backAction:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)disconnectAction:(id)sender {
	[ApplicationDelegate disconnectUser];
}

- (void)goToHome {
	[ApplicationDelegate.currentNavigationController goToHome];
}

@end
