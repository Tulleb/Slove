//
//  SLVPictureTextField.m
//  Slove
//
//  Created by Guillaume Bellut on 20/09/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPictureTextField.h"

@implementation SLVPictureTextField

// Placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 40 / 2, bounds.size.height), 40, 10);
}

// Text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
	return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width + 40 / 2, bounds.size.height), 40, 10);
}

@end
