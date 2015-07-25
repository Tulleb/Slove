//
//  SLVUsernameViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 25/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVUsernameViewController : SLVViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;

- (IBAction)confirmAction:(id)sender;

@end
