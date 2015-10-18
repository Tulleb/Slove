//
//  SLVContactViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVContactViewController.h"
#import "SLVSloveSentPopupViewController.h"
#import "SLVInteractionPopupViewController.h"
#import "SLVAddressBookContact.h"
#import "SLVLevel.h"

@interface SLVContactViewController ()

@end

@implementation SLVContactViewController

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
	
	self.levelCarousel.type = iCarouselTypeCoverFlow2;
	self.levelCarousel.userInteractionEnabled = NO;
	
	self.pictureImageView.image = self.contact.picture;
	self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.pictureImageView.clipsToBounds = YES;
	
	[self loadBackButton];
	
	// To call viewWillAppear after return from Slove Sent popup
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didDismissSloveSentPopup)
												 name:NOTIFICATION_SLOVE_SENT_POPUP_DISMISSED
											   object:nil];
	
	[self.levelCarousel scrollToItemAtIndex:self.contact.currentLevel.number - 1 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
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
	
	NSString *levelKey = [NSString stringWithFormat:@"%@-%@", KEY_CONTACT_LEVELUP, self.contact.username];
	NSNumber *level = [USER_DEFAULTS objectForKey:levelKey];
	if (level && [level intValue] != self.contact.currentLevel.number) {
		self.contact.currentLevel = [ApplicationDelegate.levels objectAtIndex:[level intValue] - 1];
		
		[USER_DEFAULTS removeObjectForKey:levelKey];
		
		[self startLevelAnimation];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.levelCarousel hideByFadingWithDuration:SHORT_ANIMATION_DURATION AndCompletion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = NO;
	
	[super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	self.spiraleYConstraint.constant = -(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) / 2;
	self.bubbleLabelTopLayoutConstraint.constant = SCREEN_HEIGHT * 0.07;
	self.levelCarouselBottomLayoutConstraint.constant = SLOVE_BUTTON_SIZE;
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
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {		
		SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
		[self.navigationController presentViewController:presentedViewController animated:YES completion:^{
			[USER_DEFAULTS setObject:[NSNumber numberWithBool:NO] forKey:KEY_FIRST_TIME_TUTORIAL];
		}];
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
		
		NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"label_smsInvite", nil), [ApplicationDelegate.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL]];
		
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

- (void)startLevelAnimation {
	[self.levelCarousel scrollToItemAtIndex:self.contact.currentLevel.number - 1 duration:VERY_LONG_ANIMATION_DURATION];
}

- (void)didDismissSloveSentPopup {
	if (!IS_IOS7) {
		[self viewDidAppear:YES];
	}
}

- (void)rotateSpirale {
	self.spiraleAngle += 18 * TIMER_FREQUENCY * (1 + MAX(ApplicationDelegate.currentNavigationController.sloveClickDuration, ApplicationDelegate.currentNavigationController.sloveClickDecelerationDuration) * 15);
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
	ApplicationDelegate.currentNavigationController.profileButton.userInteractionEnabled = NO;
	self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)enableElementsForTutorial {
	ApplicationDelegate.currentNavigationController.activityButton.userInteractionEnabled = YES;
	ApplicationDelegate.currentNavigationController.homeButton.userInteractionEnabled = YES;
	ApplicationDelegate.currentNavigationController.profileButton.userInteractionEnabled = YES;
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - iCarouselDelegate

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
	//return the total number of items in the carousel
	return [ApplicationDelegate.levels count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
	UILabel *label = nil;
	
	//create new view if no view is available for recycling
	if (view == nil) {
		//don't do anything specific to the index within
		//this `if (view == nil) {...}` statement because the view will be
		//recycled and used with other index values later
		view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
		view.contentMode = UIViewContentModeCenter;
		view.backgroundColor = RED;
		
		label = [[UILabel alloc] initWithFrame:view.bounds];
		[view addSubview:label];
	} else {
		//get a reference to the label in the recycled view
		label = (UILabel *)[view viewWithTag:1];
	}
	
	[SLVViewController setStyle:view];
	
	SLVLevel *level = [ApplicationDelegate.levels objectAtIndex:index];
	
	//set item label
	//remember to always set any properties of your carousel item
	//views outside of the `if (view == nil) {...}` check otherwise
	//you'll get weird issues with carousel item content appearing
	//in the wrong place in the carousel
	((UIImageView *)view).image = level.picture;
	label.text = level.name;
	
	return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	if (option == iCarouselOptionSpacing) {
		return value * 1.1;
	}
	
	return value;
}

@end
