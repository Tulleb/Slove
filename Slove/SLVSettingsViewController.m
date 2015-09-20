//
//  SLVSettingsViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVSettingsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SLVConstructionPopupViewController.h"

@interface SLVSettingsViewController ()

@end

@implementation SLVSettingsViewController

- (void)viewDidLoad {
	self.appName = @"settings";
	
    [super viewDidLoad];
	
	[self loadBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if (![userDefaults objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] || ![[userDefaults objectForKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED] boolValue]) {
		SLVConstructionPopupViewController *constructionPopup = [[SLVConstructionPopupViewController alloc] init];
		
		[self.navigationController presentViewController:constructionPopup animated:YES completion:nil];
		
		[userDefaults setObject:[NSNumber numberWithBool:YES] forKey:KEY_SETTINGS_CONSTRUCTION_DISPLAYED];
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
	
//	[imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//		if (!error) {
//			PFUser *user = [PFUser currentUser];
//			
//			if (![user objectForKey:@"pictureUrl"]) {
//				user[@"pictureUrl"] = url;
//				SLVLog(@"User's profile picture retrieved from Facebook");
//				
//				[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//					if (error) {
//						SLVLog(@"%@%@", SLV_ERROR, error.description);
//						[ParseErrorHandlingController handleParseError:error];
//					}
//				}];
//			// The image has now been uploaded to Parse. Associate it with a new object
//			PFObject* newPhotoObject = [PFObject objectWithClassName:@"PhotoObject"];
//			[newPhotoObject setObject:imageFile forKey:@"image"];
//			
//			[newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//				if (!error) {
//					NSLog(@"Saved");
//				}
//				else{
//					// Error
//					NSLog(@"Error: %@ %@", error, [error userInfo]);
//				}
//			}];
//		} else {
//			SLVLog(@"%@%@", SLV_ERROR, error.description);
//			[ParseErrorHandlingController handleParseError:error];
//		}
//	}];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
