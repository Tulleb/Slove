//
//  SLVConfirmationCodeViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVConfirmationCodeViewController : SLVViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSString *currentPhoneNumber;
@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UILabel *bannerLabel;
@property (strong, nonatomic) IBOutlet UITextField *confirmationNumberField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leftBannerLabelLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;

- (id)initWithPhoneNumber:(NSString *)phoneNumber;
- (IBAction)confirmAction:(id)sender;

@end
