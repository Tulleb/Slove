//
//  SLVFacebookFriend.m
//  Slove
//
//  Created by Guillaume Bellut on 06/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVFacebookFriend.h"

@implementation SLVFacebookFriend

- (NSString *)description {
	return [[super description] stringByAppendingString:[NSString stringWithFormat:@"Facebook ID = %@", self.facebookId]];
}

@end
