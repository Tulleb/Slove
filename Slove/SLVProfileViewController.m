//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"
#import "SLVSloveSentPopupViewController.h"
#import "SLVInteractionPopupViewController.h"
#import "SLVAddressBookContact.h"

@interface SLVProfileViewController ()

@end

@implementation SLVProfileViewController

- (id)initWithContact:(SLVContact *)contact {
	self = [super init];
	
	if (self) {
		self.contact = contact;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.contact.username && ![self.contact.username isEqualToString:@""]) {
		self.title = self.contact.username;
	} else {
		self.title = self.contact.fullName;
	}
	
	self.spiraleImageView.image = [UIImage imageNamed:@"Assets/Button/bt_spirale_rotation"];
	self.bubbleImageView.image = [UIImage imageNamed:@"Assets/Image/infobulle_slove"];
	self.bubblePicto.image = [UIImage imageNamed:@"Assets/Image/picto_tap_2secondes"];
	
	[self loadBackButton];
	
	// To call viewWillAppear after return from Slove Sent popup
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didDismissSloveSentPopup)
												 name:NOTIFICATION_SLOVE_SENT_POPUP_DISMISSED
											   object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.contact) {
		if (self.contact.picture) {
			self.pictureImageView.hidden = NO;
			self.pictureImageView.image = self.contact.picture;
			self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
			self.pictureImageView.clipsToBounds = YES;
		} else {
			self.pictureImageView.hidden = YES;
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		[self disableElementsForTutorial];
		self.bubbleView.hidden = NO;
		
		[UIView animateWithDuration:ANIMATION_DURATION animations:^{
			self.bubbleView.alpha = 1;
		}];
		
	} else if (!self.bubbleView.hidden) {
		[self enableElementsForTutorial];
		self.bubbleView.hidden = YES;
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = NO;
	
	[super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.spiraleYConstraint.constant = -(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) / 2;
	self.bubbleLabelTopLayoutConstraint.constant = SCREEN_HEIGHT * 0.07;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	UIImage *_maskingImage = [UIImage imageNamed:@"Assets/Layer/layer_profile_picture"];
	CALayer *_maskingLayer = [CALayer layer];
	_maskingLayer.frame = self.pictureImageView.bounds;
	[_maskingLayer setContents:(id)[_maskingImage CGImage]];
	[self.pictureImageView.layer setMask:_maskingLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateImages {
	[self rotateSpirale];
	
	[self loadCircle];
}

- (IBAction)sloveAction:(id)sender {
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		[SLVTools playSound:SLOVER_SOUND];
		
		SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
		[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
	} else if (!self.contact.username) {
		if(![MFMessageComposeViewController canSendText]) {
			SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_smsInvite", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_ok", nil), nil] andDismissButton:NO];
			[self presentViewController:errorPopup animated:YES completion:nil];
			
			return;
		}
		
		NSMutableArray *recipents = [[NSMutableArray alloc] init];
		SLVAddressBookContact *addressBookContact = (SLVAddressBookContact *)self.contact;
		for (NSDictionary *phoneNumberDic in addressBookContact.phoneNumbers) {
			[recipents addObject:[phoneNumberDic objectForKey:@"formatedPhoneNumber"]];
		}
		
		NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"label_smsInvite", nil), NSLocalizedString(@"url_smsInvite", nil)];
		
		MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
		messageController.messageComposeDelegate = self;
		[messageController setRecipients:recipents];
		[messageController setBody:message];
		
		[self presentViewController:messageController animated:YES completion:nil];
	} else {
		[PFCloud callFunctionInBackground:SEND_SLOVE_FUNCTION
						   withParameters:@{@"username" : self.contact.username}
									block:^(id object, NSError *error){
										if (!error) {
											[SLVTools playSound:SLOVER_SOUND];
											
											SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
											[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
											
											[ApplicationDelegate.currentNavigationController refreshSloveCounter];
										} else {
											SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(error.localizedDescription, nil) buttonsTitle:nil andDismissButton:YES];
											[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
											
											SLVLog(@"%@%@", SLV_ERROR, error.description);
											[ParseErrorHandlingController handleParseError:error];
										}
									}];
	}
}

- (void)didDismissSloveSentPopup {
	if (!IS_IOS7) {
		[self viewDidAppear:YES];
	}
}

- (void)rotateSpirale {
	self.spiraleAngle += 18 * TIMER_FREQUENCY * (1 + ApplicationDelegate.currentNavigationController.sloveClickDuration * 15);
	[UIView animateWithDuration:TIMER_FREQUENCY
						  delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 self.spiraleImageView.transform = CGAffineTransformMakeRotation(degreesToRadians(self.spiraleAngle));
					 }
					 completion:^(BOOL success) {
						 [self rotateSpirale];
					 }];
}

- (void)loadCircle {
	self.circleImageView.image = [UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi48"];
	
	NSMutableArray *animatedImages = [[NSMutableArray alloc] init];
	NSString *prefixImageName = @"Assets/Animation/Envoi_Slove/animenvoi";
	
	for (int i = 1; i <= 48; i++) {
		if (i < 10) {
			[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"0%d", i]]] atIndex:i - 1];
		} else {
			[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%d", i]]] atIndex:i - 1];
		}
	}
	
	self.circleImageView.animationImages = animatedImages;
	self.circleImageView.animationDuration = 2;
	self.circleImageView.animationRepeatCount = 1;
}

- (void)disableElementsForTutorial {
	ApplicationDelegate.currentNavigationController.activityButton.userInteractionEnabled = NO;
	ApplicationDelegate.currentNavigationController.homeButton.userInteractionEnabled = NO;
	ApplicationDelegate.currentNavigationController.settingsButton.userInteractionEnabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)enableElementsForTutorial {
	ApplicationDelegate.currentNavigationController.activityButton.userInteractionEnabled = YES;
	ApplicationDelegate.currentNavigationController.homeButton.userInteractionEnabled = YES;
	ApplicationDelegate.currentNavigationController.settingsButton.userInteractionEnabled = YES;
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
