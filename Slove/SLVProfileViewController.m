//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"
#import "SLVConstructionPopupViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface SLVProfileViewController ()

@end

@implementation SLVProfileViewController

- (void)viewDidLoad {
	self.appName = @"profile";
	
    [super viewDidLoad];
	
	PFUser *currentUser = [PFUser currentUser];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/profil_banniere"];
	self.levelImageView.image = [UIImage imageNamed:@"Assets/Image/niveau_profil_debutant"];
	self.counterImageView.image = [UIImage imageNamed:@"Assets/Box/compteur_slove"];
	self.counterDescriptionImageView.image = [UIImage imageNamed:@"Assets/Image/fleche_label_compteur"];
	self.topBarImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
	self.bottomBarImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
	self.profilePictureLayerImageView.image = [UIImage imageNamed:@"Assets/Layer/masque_profil_repertoire"];
	self.pictoImageView.image = [UIImage imageNamed:@"Assets/Image/coeur_rouge"];
	self.profilePictureImageView.image = [UIImage imageNamed:@"Assets/Avatar/avatar_user"];
	
	self.profilePictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	self.profilePictureImageView.clipsToBounds = YES;
	
	NSString *profilePictureUrl = [currentUser objectForKey:@"pictureUrl"];
	if (profilePictureUrl && ![profilePictureUrl isEqualToString:@""]) {
		[self.profilePictureImageView setImageWithURL:[NSURL URLWithString:profilePictureUrl] placeholderImage:[UIImage imageNamed:@"Assets/Avatar/avatar_user"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	}
	
	NSNumber *sloveCounter = [currentUser objectForKey:@"sloveCounter"];
	if ([sloveCounter intValue] < 100) {
		self.counterLabel.text = [NSString stringWithFormat:@"***%03d", [sloveCounter intValue]];
	} else if ([sloveCounter intValue] < 1000) {
		self.counterLabel.text = [NSString stringWithFormat:@"**%04d", [sloveCounter intValue]];
	} else if ([sloveCounter intValue] < 10000) {
		self.counterLabel.text = [NSString stringWithFormat:@"*%05d", [sloveCounter intValue]];
	} else {
		self.counterLabel.text = [NSString stringWithFormat:@"%d", [sloveCounter intValue]];
	}
	
	self.counterLabel.textColor = WHITE;
	self.counterLabel.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
	
	self.counterDescriptionLabel.textColor = WHITE;
	self.counterDescriptionLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_VERY_SMALL];
	
	NSString *fullName = @"";
	NSString *firstName = [currentUser objectForKey:@"firstName"];
	
	if (firstName) {
		fullName = [fullName stringByAppendingString:firstName];
	}
	
	NSString *lastName = [currentUser objectForKey:@"lastName"];
	
	if (lastName) {
		if (![fullName isEqualToString:@""]) {
			fullName = [fullName stringByAppendingString:@" "];
		}
		
		fullName = [fullName stringByAppendingString:lastName];
	}
	
	self.fullNameLabel.text = fullName;
	self.fullNameLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE];
	
	self.usernameLabel.text = [currentUser objectForKey:@"username"];
	self.usernameLabel.textColor = BLUE;
	self.usernameLabel.font = [UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE_SMALL];
	
	[self.uploadProfilePictureButton setTitleColor:BLUE forState:UIControlStateNormal];
	
	[self loadBackButton];
	[self loadLogoutButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	ApplicationDelegate.currentNavigationController.profileButton.selected = YES;
	
//	if (![USER_DEFAULTS objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] || ![[USER_DEFAULTS objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] boolValue]) {
//		SLVConstructionPopupViewController *constructionPopup = [[SLVConstructionPopupViewController alloc] init];
//		
//		[self.navigationController presentViewController:constructionPopup animated:YES completion:nil];
//		
//		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED];
//	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	ApplicationDelegate.currentNavigationController.profileButton.selected = NO;
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	if (IS_3INCH5) {
		self.leftLevelLayoutConstraint.constant = 13;
		self.rightCounterLayoutConstraint.constant = 13;
	} else if (IS_4INCH) {
		self.leftLevelLayoutConstraint.constant = 13;
		self.rightCounterLayoutConstraint.constant = 13;
	} else if (IS_4INCH7) {
		self.leftLevelLayoutConstraint.constant = 21;
		self.rightCounterLayoutConstraint.constant = 21;
	} else if (IS_5INCH5) {
		self.leftLevelLayoutConstraint.constant = 28;
		self.rightCounterLayoutConstraint.constant = 28;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadProfilePictureAction:(id)sender {
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
	imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)backAction:(id)sender {
	[super goToHome];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSURL *imagePath = [info objectForKey:UIImagePickerControllerReferenceURL];
	NSString *imageName = [imagePath lastPathComponent];
	NSString *imageExtension = [imageName substringFromIndex:[imageName length] - 3];
	NSString *imageFullName = [NSString stringWithFormat:@"%@.%@", imageName, imageExtension];
	
	NSData* data = UIImageJPEGRepresentation(image, 1);
	PFFile *imageFile = [PFFile fileWithName:imageFullName data:data];
	
	[self.uploadProgressBar showByFadingWithDuration:SHORT_ANIMATION_DURATION AndCompletion:nil];
	
	[imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		[self.uploadProgressBar hideByFadingWithDuration:SHORT_ANIMATION_DURATION AndCompletion:^{
			self.uploadProgressBar.progress = 0;
		}];
		
		if (succeeded) {
			PFUser *user = [PFUser currentUser];
			
			user[@"pictureUrl"] = imageFile.url;
			user[@"picture"] = imageFile;
			
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error) {
					SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_upload_image_error", nil) buttonsTitle:nil andDismissButton:YES];
					[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
					
					SLVLog(@"%@%@", SLV_ERROR, error.description);
					[ParseErrorHandlingController handleParseError:error];
				} else {
					NSString *profilePictureUrl = [[PFUser currentUser] objectForKey:@"pictureUrl"];
					if (profilePictureUrl && ![profilePictureUrl isEqualToString:@""]) {
						[self.profilePictureImageView setImageWithURL:[NSURL URLWithString:profilePictureUrl] placeholderImage:[UIImage imageNamed:@"Assets/Avatar/avatar_user"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
					}
				}
			}];
			
			[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Profile"
																	   action:@"Upload picture"
																		label:@"Succeed"
																		value:@1] build]];
			
			[[Amplitude instance] logEvent:@"[Profile] Upload picture succeed"];
		} else {
			SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_upload_image_error", nil) buttonsTitle:nil andDismissButton:YES];
			[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
			
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
			
			[self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Profile"
																	   action:@"Upload picture"
																		label:@"Failed"
																		value:@1] build]];
			
			NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
			[eventProperties setValue:error.localizedDescription forKey:@"Value"];
			[[Amplitude instance] logEvent:@"[Profile] Upload picture failed" withEventProperties:eventProperties];
		}
	} progressBlock:^(int percentDone) {
		self.uploadProgressBar.progress = percentDone / 100.0;
	}];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
