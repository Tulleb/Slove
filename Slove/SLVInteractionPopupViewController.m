//
//  SLVInteractionPopupViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 16/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVInteractionPopupViewController.h"

@interface SLVInteractionPopupViewController ()

@end

@implementation SLVInteractionPopupViewController

- (id)initWithTitle:(NSString *)title body:(NSString *)body buttonsTitle:(NSArray *)buttonTitles andDismissButton:(BOOL)dismissShouldDisplayed {
	self = [super init];
	if (self) {
		self.popupTitle = title;
		self.popupBody = body;
		self.buttonTitles = buttonTitles;
		self.dismissShouldDisplayed = dismissShouldDisplayed;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.popupView.backgroundColor = BLUE_ALPHA;
	
	[self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_close_popup"] forState:UIControlStateNormal];
	[self.dismissButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_close_popup_clic"] forState:UIControlStateHighlighted];
	
	self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_LARGE];
	self.titleLabel.text = self.popupTitle;
	self.titleLabel.textColor = WHITE;
	
	self.bodyLabel.text = [NSString stringWithFormat:@"%@", self.popupBody];
	self.bodyLabel.textColor = WHITE;
	
	switch ([self.buttonTitles count]) {
		case 1: {
			self.soloButton.hidden = NO;
			[self.soloButton setTitle:[self.buttonTitles firstObject] forState:UIControlStateNormal];
			break;
		}
			
		case 2: {
			self.buttonA.hidden = NO;
			self.buttonB.hidden = NO;
			
			[self.buttonA setTitle:[self.buttonTitles firstObject] forState:UIControlStateNormal];
			[self.buttonB setTitle:[self.buttonTitles lastObject] forState:UIControlStateNormal];
			break;
		}
			
		default:
			break;
	}
	
	[self.soloButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup"] forState:UIControlStateNormal];
	[self.buttonA setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup"] forState:UIControlStateNormal];
	[self.buttonB setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup"] forState:UIControlStateNormal];
	
	[self.soloButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup_clic"] forState:UIControlStateHighlighted];
	[self.buttonA setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup_clic"] forState:UIControlStateHighlighted];
	[self.buttonB setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_popup_clic"] forState:UIControlStateHighlighted];
	
	self.dismissButton.hidden = !self.dismissShouldDisplayed;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.rightBorderConstraint.constant = self.popupImageView.frame.size.width * 0.09;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)soloButtonAction:(id)sender {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(soloButtonPressed:)]) {
			[self.delegate performSelector:@selector(soloButtonPressed:) withObject:self];
		} else {
			SLVLog(@"%@No function 'soloButtonPressed:' in %@", SLV_ERROR, self.delegate);
		}
	} else {
		SLVLog(@"%@No delegate defined", SLV_ERROR);
	}
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonAAction:(id)sender {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(buttonAPressed:)]) {
			[self.delegate performSelector:@selector(buttonAPressed:) withObject:self];
		} else {
			SLVLog(@"%@No function 'buttonAPressed:' in %@", SLV_ERROR, self.delegate);
		}	} else {
		SLVLog(@"%@No delegate defined", SLV_ERROR);
	}
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)buttonBAction:(id)sender {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(buttonBPressed:)]) {
			[self.delegate performSelector:@selector(buttonBPressed:) withObject:self];
		} else {
			SLVLog(@"%@No function 'buttonBPressed:' in %@", SLV_ERROR, self.delegate);
		}
	} else {
		SLVLog(@"%@No delegate defined", SLV_ERROR);
	}
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender {
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(dismissButtonPressed:)]) {
			[self.delegate performSelector:@selector(dismissButtonPressed:) withObject:self];
		} else {
			SLVLog(@"%@No function 'dismissButtonPressed:' in %@", SLV_ERROR, self.delegate);
		}
	} else {
		SLVLog(@"%@No delegate defined", SLV_ERROR);
	}
	
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)animateImages {
	NSMutableArray *animatedImages = [[NSMutableArray alloc] init];
	NSString *prefixImageName = @"Assets/Animation/anim_popup/anim_popup";
	
	for (int i = 1; i <= 2; i++) {
		[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%d", i]]] atIndex:i - 1];
	}
	
	self.popupImageView.animationImages = animatedImages;
	self.popupImageView.animationDuration = 0.2;
	self.popupImageView.animationRepeatCount = 0;
	[self.popupImageView startAnimating];
}

@end
