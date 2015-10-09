//
//  SLVSettingsViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 29/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVSettingsViewController : SLVViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)uploadProfilePictureAction:(id)sender;
- (IBAction)disconnectAction:(id)sender;

@end
