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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#define LOCKER_IMAGE_VIEW_TAG	593

@interface SLVContactViewController ()

@end

@implementation SLVContactViewController

- (id)initWithContact:(SLVContact *)contact andPicture:(UIImage *)picture {
	self = [super init];
	if (self) {
		self.contact = contact;
		self.pictureImage = picture;
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
	
	self.levelCarousel.type = iCarouselTypeCustom;
	self.levelCarousel.userInteractionEnabled = NO;
	self.levelCarousel.hidden = [self.contact.username isEqualToString:PUPPY_USERNAME];
	
	if (self.contact.pictureUrl) {
		[self.pictureImageView setImageWithURL:self.contact.pictureUrl placeholderImage:[UIImage imageNamed:@"Assets/Avatar/avatar_user"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	} else if ([self.contact isKindOfClass:[SLVAddressBookContact class]] && ((SLVAddressBookContact *)self.contact).picture) {
		self.pictureImageView.image = ((SLVAddressBookContact *)self.contact).picture;
	} else if (self.pictureImage) {
		self.pictureImageView.image = self.pictureImage;
	} else {
		self.pictureImageView.image = [UIImage imageNamed:@"Assets/Avatar/avatar_user_big"];
	}
	self.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.pictureImageView.clipsToBounds = YES;
	
	[self loadBackButton];
	
	// To call viewWillAppear after return from Slove Sent popup
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didDismissSloveSentPopup)
												 name:NOTIFICATION_SLOVE_SENT_POPUP_DISMISSED
											   object:nil];
	
	[self.levelCarousel scrollToItemAtIndex:self.contact.currentLevel.number animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.levelCarousel showByFadingWithDuration:SHORT_ANIMATION_DURATION AndCompletion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue] && !ApplicationDelegate.tutorialSloveSent) {
		[ApplicationDelegate disableNavigationElements];
		[self.bubbleView showByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
	} else if (!self.bubbleView.hidden) {
		[ApplicationDelegate enableNavigationElements];
		self.bubbleView.hidden = YES;
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	} else if ([self.contact.username isEqualToString:PUPPY_USERNAME]) {
		if (![[USER_DEFAULTS objectForKey:KEY_PUPPY_NO_LEVEL_DISPLAYED] boolValue]) {
			SLVInteractionPopupViewController *warningPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_no_level_available", nil) buttonsTitle:nil andDismissButton:YES];
			[self.navigationController presentViewController:warningPopup animated:YES completion:^{
				[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_PUPPY_NO_LEVEL_DISPLAYED];
			}];
		}
	} else {
		[self checkLevel];
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
	if (!IS_IOS7) {
		[self rotateSpirale];
	}
	
	[self loadCircle];
	[self loadFirework];
}

- (IBAction)sloveAction:(id)sender {
	if ([[USER_DEFAULTS objectForKey:KEY_FIRST_TIME_TUTORIAL] boolValue]) {
		SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
		[self.navigationController presentViewController:presentedViewController animated:YES completion:^{
			ApplicationDelegate.tutorialSloveSent = YES;
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
	} else if ([self.contact.username isEqualToString:PUPPY_USERNAME]) {
		if (ApplicationDelegate.puppyPush) {
			SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_already_sloved_recently", nil) buttonsTitle:nil andDismissButton:YES];
			[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
		} else {
			[[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *currentUser,  NSError *error) {
				if (!error) {
					NSDictionary *data = @{@"alert" : [NSString stringWithFormat:@"♥ New Slove from %@ ♥", PUPPY_USERNAME],
										   @"badge" : @"Increment",
										   @"sound" : SLOVED_SOUND_PATH,
										   @"slover" : @{@"username" : PUPPY_USERNAME}};
					PFPush *push = [[PFPush alloc] init];
					[push setChannels:@[[currentUser objectForKey:@"username"]]];
					[push setData:data];
					ApplicationDelegate.puppyPush = push;
					
					SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
					[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
				} else {
					SLVLog(@"%@%@", SLV_ERROR, error.description);
					[ParseErrorHandlingController handleParseError:error];
				}
			}];
		}
	} else {
		[PFCloud callFunctionInBackground:SEND_SLOVE_FUNCTION
						   withParameters:@{@"username" : self.contact.username}
									block:^(id object, NSError *error){
										if (!error) {
											SLVLog(@"Received data from server: %@", object);
											
											[SLVTools playSound:SLOVER_SOUND_PATH];
											
											SLVSloveSentPopupViewController *presentedViewController = [[SLVSloveSentPopupViewController alloc] init];
											[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
											
											[ApplicationDelegate.currentNavigationController refreshSloveCounter];
										} else {
											NSString *errorLabel = NSLocalizedString(error.localizedDescription, nil);
											
											NSData *data = [error.localizedDescription dataUsingEncoding:NSUTF8StringEncoding];
											NSDictionary *localizedErrorDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
											
											NSString *errorCode = [localizedErrorDictionary objectForKey:@"message"];
											
											if (errorCode) {
												errorLabel = NSLocalizedString(errorCode, nil);
												
												if ([errorCode isEqualToString:@"error_not_enough_slove"]) {
													NSNumber *secondsRemaining = [localizedErrorDictionary objectForKey:@"secondsRemaining"];
													int hoursRemaining = ([secondsRemaining intValue] / 60 / 60) + 1;
													errorLabel = [errorLabel stringByReplacingOccurrencesOfString:@"[timer]" withString:[NSString stringWithFormat:@"%dh", hoursRemaining]];
												}
											}
											
											SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:errorLabel buttonsTitle:nil andDismissButton:YES];
											[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
											
											SLVLog(@"%@%@", SLV_ERROR, error.description);
											[ParseErrorHandlingController handleParseError:error];
										}
									}];
	}
}

- (void)checkLevel {
	[PFCloud callFunctionInBackground:GET_LEVEL
					   withParameters:@{@"username" : self.contact.username}
								block:^(id object, NSError *error){
									if (!error) {
										SLVLog(@"Received data from server: %@", object);
										
										NSDictionary *datas = object;
										NSNumber *level = [datas objectForKey:@"level"];
										
										if (level) {
											self.levelNumberBuffer = self.contact.currentLevel.number;
											
											self.contact.currentLevel = [ApplicationDelegate.levels objectAtIndex:[level intValue]];
											
											NSString *levelKey = [NSString stringWithFormat:@"%@-%@", KEY_CONTACT_LEVELUP, self.contact.username];
											NSNumber *currentLevel = [USER_DEFAULTS objectForKey:levelKey];
											
											if ((!currentLevel && (self.contact.currentLevel.number > 0)) || ([currentLevel intValue] != self.contact.currentLevel.number)) {
												SLVLog(@"Level up %d with %@!", self.contact.currentLevel.number, self.contact.username);
												
												[self startLevelAnimation];
												
												
											}
											
											[USER_DEFAULTS setObject:level forKey:levelKey];
										}
									} else {
										SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(error.localizedDescription, nil) buttonsTitle:nil andDismissButton:YES];
										[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
										
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}

- (void)startLevelAnimation {
	for (int i = self.levelNumberBuffer; i <= self.contact.currentLevel.number; i++) {
		[[[self.levelCarousel itemViewAtIndex:i] viewWithTag:LOCKER_IMAGE_VIEW_TAG] hideByFadingWithDuration:LONG_ANIMATION_DURATION AndCompletion:nil];
	}
	
	[self.levelCarousel scrollToItemAtIndex:self.contact.currentLevel.number duration:VERY_LONG_ANIMATION_DURATION];
	
	[self.fireworkImageView startAnimating];
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
	self.circleImageView.animationDuration = VERY_LONG_ANIMATION_DURATION;
	self.circleImageView.animationRepeatCount = 1;
}

- (void)loadFirework {
	self.fireworkImageView.image = [UIImage imageNamed:@"Assets/Animation/firework/feudartifice-v10001"];
	
	NSMutableArray *animatedImages = [[NSMutableArray alloc] init];
	NSString *prefixImageName = @"Assets/Animation/firework/feudartifice-v100";
	
	for (int i = 1; i <= 32; i++) {
		[animatedImages insertObject:[UIImage imageNamed:[prefixImageName stringByAppendingString:[NSString stringWithFormat:@"%02d", i]]] atIndex:i - 1];
	}
	
	self.fireworkImageView.animationImages = animatedImages;
	self.fireworkImageView.animationDuration = VERY_LONG_ANIMATION_DURATION;
	self.fireworkImageView.animationRepeatCount = 1;
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
	UIImageView *boxImageView = nil;
	UIImageView *lockerImageView = nil;
	UIImageView *levelImageView = nil;
	
	UILabel *levelLabel = nil;
	UIImageView *numberImageView = nil;
	UILabel *numberLabel = nil;
	
	//create new view if no view is available for recycling
	if (view == nil) {
		//don't do anything specific to the index within
		//this `if (view == nil) {...}` statement because the view will be
		//recycled and used with other index values later
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 117, 80)];
		//		view.contentMode = UIViewContentModeCenter;
		
		boxImageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width - 117) / 2, 0, 117, 80)];
		lockerImageView = [[UIImageView alloc] initWithFrame:boxImageView.frame];
		levelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(boxImageView.frame.origin.x + (boxImageView.frame.size.width - 80) / 2, (boxImageView.frame.size.height - 40) / 2 - 10, 80, 40)];
		
		levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(boxImageView.frame.origin.x + 27, 55, 40, 20)];
		levelLabel.textAlignment = NSTextAlignmentRight;
		numberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(levelLabel.frame.origin.x + levelLabel.frame.size.width + 5,  levelLabel.frame.origin.y + (levelLabel.frame.size.height - 15) / 2, 16, 15)];
		numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(numberImageView.frame.origin.x + 4, numberImageView.frame.origin.y, numberImageView.frame.size.width, numberImageView.frame.size.height)];
		
		[view addSubview:boxImageView];
		[view addSubview:lockerImageView];
		[view addSubview:levelImageView];
		[view addSubview:numberImageView];
		[view addSubview:levelLabel];
		[view addSubview:numberLabel];
		
		[view bringSubviewToFront:lockerImageView];
	}
//	else {
//		//get a reference to the label in the recycled view
//		label = (UILabel *)[view viewWithTag:1];
//	}
	
	[SLVViewController setStyle:view];
	
	SLVLevel *level = [ApplicationDelegate.levels objectAtIndex:index];
	
	boxImageView.image = [UIImage imageNamed:@"Assets/Box/bloc_niveau"];
	
	lockerImageView.image = [UIImage imageNamed:@"Assets/Box/bloc_niveau_cadenas"];
	lockerImageView.tag = LOCKER_IMAGE_VIEW_TAG;
	
	levelImageView.image = level.picture;
	
	numberImageView.image = [UIImage imageNamed:@"Assets/Image/coeur_numero_niveau"];
	
	levelLabel.text = NSLocalizedString(@"level", nil);
	
	numberLabel.text = [NSString stringWithFormat:@"%d", level.number];
	numberLabel.textColor = WHITE;
	numberLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_VERY_SMALL];
	
	BOOL levelIsReached = (level.number <= self.contact.currentLevel.number);
	
	if (levelIsReached) {
		lockerImageView.hidden = YES;
	}
	
	return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
	if (option == iCarouselOptionSpacing) {
		return value * 2;
	}
	
	return value;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
	return 100;
}

- (CATransform3D)carousel:(iCarousel *)carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform {
	CGFloat distance = SCREEN_HEIGHT / 4; //number of pixels to move the items away from camera
	CGFloat z = -fabs(offset) * distance;
	return CATransform3DTranslate(transform, offset * carousel.itemWidth, ABS(offset) * -20, z);
}

@end
