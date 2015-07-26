//
//  SLVPhoneNumberViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVPhoneNumberViewController : SLVViewController

@property (strong, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)confirmAction:(id)sender;

@end
