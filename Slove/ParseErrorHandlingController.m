//
//  ParseErrorHandlingController.m
//  Slove
//
//  Created by Guillaume Bellut on 26/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "ParseErrorHandlingController.h"
#import "SLVLogInViewController.h"

@implementation ParseErrorHandlingController

+ (void)handleParseError:(NSError *)error {
	if (![error.domain isEqualToString:PFParseErrorDomain]) {
		return;
	}
	
	switch (error.code) {
		case kPFErrorInvalidSessionToken: {
			[self _handleInvalidSessionTokenError];
			break;
		}
	}
}

+ (void)_handleInvalidSessionTokenError {
	//--------------------------------------
	// Option 1: Show a message asking the user to log out and log back in.
	//--------------------------------------
	// If the user needs to finish what they were doing, they have the opportunity to do so.
	//
	// UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Session"
	//                                                     message:@"Session is no longer valid, please log out and log in again."
	//                                                    delegate:self
	//                                           cancelButtonTitle:@"Not Now"
	//                                           otherButtonTitles:@"OK"];
	// [alertView show];
	
	//--------------------------------------
	// Option #2: Show login screen so user can re-authenticate.
	//--------------------------------------
	// You may want this if the logout button is inaccessible in the UI.
	//
	[ApplicationDelegate userIsDisconnected];
}

@end
