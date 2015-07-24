//
//  Route.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "Route.h"
#import <Parse/PFObject+Subclass.h>

@implementation Route

+ (void)load {
	[self registerSubclass];
}

+ (NSString *)parseClassName {
	return @"Armor";
}

@end
