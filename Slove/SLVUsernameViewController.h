//
//  SLVUsernameViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 25/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVUsernameViewController : SLVViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;
@property (nonatomic) BOOL keyboardIsVisible;

- (IBAction)confirmAction:(id)sender;

@end
