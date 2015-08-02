//
//  SLVAddressBookContact.m
//  Slove
//
//  Created by Guillaume Bellut on 01/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVAddressBookContact.h"

@implementation SLVAddressBookContact

- (NSString *)description {
	NSString *phoneNumbers = @"Phone numbers =\n";
	
	for (NSString *phoneNumber in self.phoneNumbers) {
		phoneNumbers = [phoneNumbers stringByAppendingString:[NSString stringWithFormat:@"%@\n", phoneNumber]];
	}
	
	return [[super description] stringByAppendingString:phoneNumbers];
}

@end
