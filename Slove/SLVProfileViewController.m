//
//  SLVProfileViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVProfileViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SLVConstructionPopupViewController.h"

@interface SLVProfileViewController ()

@end

@implementation SLVProfileViewController

- (void)viewDidLoad {
	self.appName = @"profile";
	
    [super viewDidLoad];
	
	[self loadBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	if (![USER_DEFAULTS objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] || ![[USER_DEFAULTS objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] boolValue]) {
		SLVConstructionPopupViewController *constructionPopup = [[SLVConstructionPopupViewController alloc] init];
		
		[self.navigationController presentViewController:constructionPopup animated:YES completion:nil];
		
		[USER_DEFAULTS setObject:[NSNumber numberWithBool:YES] forKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED];
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

- (IBAction)disconnectAction:(id)sender {
	if ([FBSDKAccessToken currentAccessToken]) {
		[FBSDKAccessToken setCurrentAccessToken:nil];
	}
	
	[PFUser logOutInBackgroundWithBlock:^(NSError * error) {
		if (!error) {
			[ApplicationDelegate userDisconnected];
		} else {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
}

- (void)goBack:(id)sender {
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
	
	[imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (!error) {
			PFUser *user = [PFUser currentUser];
			
			user[@"pictureUrl"] = imageFile.url;
			
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				if (error) {
					SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_upload_image_error", nil) buttonsTitle:nil andDismissButton:YES];
					[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
					
					SLVLog(@"%@%@", SLV_ERROR, error.description);
					[ParseErrorHandlingController handleParseError:error];
				}
			}];
		} else {
			SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_upload_image_error", nil) buttonsTitle:nil andDismissButton:YES];
			[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
			
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
	}];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
