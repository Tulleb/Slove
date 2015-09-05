//
//  SLVTextField.m
//  Slove
//
//  Created by Guillaume Bellut on 05/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVTextField.h"

@implementation SLVTextField

// Placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 15 / 2, bounds.size.height), 15, 10);
}

// Text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
	return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 15 / 2, bounds.size.height), 15, 10);
}

@end
