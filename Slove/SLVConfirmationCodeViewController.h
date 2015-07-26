//
//  SLVConfirmationCodeViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVConfirmationCodeViewController : SLVViewController {
	NSString *currentPhoneNumber;
}

@property (strong, nonatomic) IBOutlet UITextField *confirmationNumberField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

- (id)initWithPhoneNumber:(NSString *)phoneNumber;
- (IBAction)confirmAction:(id)sender;

@end
