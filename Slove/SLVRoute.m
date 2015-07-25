//
//  Route.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVRoute.h"
#import <Parse/PFObject+Subclass.h>

@implementation SLVRoute

@synthesize stringURL, method;

+ (void)load {
	[self registerSubclass];
}

+ (NSString *)parseClassName {
	return @"Route";
}

@end
