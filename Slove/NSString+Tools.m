//
//  NSString+Tools.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "NSString+Tools.h"

@implementation NSString (Tools)

- (NSString *)MD5{
	// Create pointer to the string as UTF8
	const char *ptr = [self UTF8String];
	
	// Create byte array of unsigned chars
	unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
	
	// Create 16 bytes MD5 hash value, store in buffer
	CC_MD5(ptr, (uint)strlen(ptr), md5Buffer);
	
	// Convert unsigned char buffer to NSString of hex values
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x",md5Buffer[i]];
	
	return output;
}

- (NSString *)addSpaceBetweenUppercase {
	NSRegularExpression *regexp = [NSRegularExpression
								   regularExpressionWithPattern:@"([a-z])([A-Z])"
								   options:0
								   error:NULL];
	NSString *newString = [regexp
						   stringByReplacingMatchesInString:self
						   options:0
						   range:NSMakeRange(0, self.length)
						   withTemplate:@"$1 $2"];
	return newString;
}

- (NSString *)removeAccents {
	NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
