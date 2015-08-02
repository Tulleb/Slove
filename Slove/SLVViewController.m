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
	
	[SLVViewController setStyle:self.view];
	
	// To substract the navigation bar height from the view
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
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
			}
			
			[self setStyle:subview];
		}
	}
}

// Subclassed method
- (void)animateImages {
	
}

@end
