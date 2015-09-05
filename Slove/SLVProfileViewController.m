//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 09/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"
#import "SLVSloveSentViewController.h"
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
	
	self.spiraleYConstraint.constant = -(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height) / 2;
	
	[self loadBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if (self.contact) {
		self.fullNameLabel.text = self.contact.fullName;
		
		if (self.contact.username && ![self.contact.username isEqualToString:@""]) {
			self.usernameLabel.hidden = NO;
			self.sloveCounterLabel.hidden = NO;
			self.sloveButton.hidden = NO;
			
			self.usernameLabel.text = self.contact.username;
			self.sloveCounterLabel.text = [self.contact.sloveCounter stringValue];
		} else {
			self.usernameLabel.hidden = YES;
			self.sloveCounterLabel.hidden = YES;
			self.sloveButton.hidden = YES;
		}
		
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

- (void)viewDidDisappear:(BOOL)animated {
	self.navigationController.navigationBarHidden = NO;
	
	[super viewDidDisappear:animated];
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
	if (!self.contact.username) {
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
											
											SLVSloveSentViewController *presentedViewController = [[SLVSloveSentViewController alloc] init];
											[self.navigationController presentViewController:presentedViewController animated:YES completion:nil];
											
											[ApplicationDelegate.currentNavigationController refreshSloveCounter];
										} else {
											SLVLog(@"%@%@", SLV_ERROR, error.description);
											[ParseErrorHandlingController handleParseError:error];
										}
									}];
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
	
	self.circleImageView.animationImages = [NSArray arrayWithObjects:
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi00"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi01"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi02"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi03"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi04"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi05"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi06"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi07"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi08"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi09"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi10"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi11"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi12"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi13"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi14"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi15"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi16"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi17"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi18"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi19"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi20"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi21"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi22"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi23"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi24"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi25"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi26"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi27"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi28"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi29"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi30"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi31"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi32"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi33"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi34"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi35"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi36"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi37"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi38"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi39"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi40"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi41"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi42"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi43"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi44"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi45"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi46"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi47"],
											[UIImage imageNamed:@"Assets/Animation/Envoi_Slove/animenvoi48"], nil];
	
	self.circleImageView.animationDuration = 2;
	self.circleImageView.animationRepeatCount = 1;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
