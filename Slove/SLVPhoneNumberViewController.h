//
//  SLVPhoneNumberViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVPhoneNumberViewController : SLVViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UILabel *bannerLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pickerTopImageView;
@property (strong, nonatomic) IBOutlet UIImageView *pickerBackgroundImageView;
@property (strong, nonatomic) IBOutlet UIImageView *pickerBottomImageView;
@property (strong, nonatomic) IBOutlet UIPickerView *countryPickerView;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) NSString *formatedPhoneNumber;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightBannerLabelLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardLayoutConstraint;
@property (nonatomic) BOOL keyboardIsVisible;

- (IBAction)confirmAction:(id)sender;

@end
