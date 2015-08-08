//
//  SLVContact.m
//  Slove
//
//  Created by Guillaume Bellut on 28/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVContact.h"

@implementation SLVContact

- (NSString *)description {
	return [NSString stringWithFormat:@"%@:\nUsername = %@\nFull name = %@\nPhone number = %@\n", [self class], self.username, self.fullName, self.phoneNumber];
}

@end
