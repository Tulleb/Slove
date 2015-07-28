//
//  NSString+Tools.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Tools)

- (NSString *)MD5;
- (NSString *)addSpaceBetweenUppercase;
- (NSString *)removeAccents;

@end
