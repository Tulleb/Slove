//
//  SLVCountryCodeData.m
//  Slove
//
//  Created by Guillaume Bellut on 02/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVCountryCodeData.h"

@implementation SLVCountryCodeData

- (NSString *)description {
	return [NSString stringWithFormat:@"%@:\nISO code = %@,\nCountry = %@,\nCountry code = %@\n", [self class], self.ISOCode, self.country, self.countryCode];
}

@end
