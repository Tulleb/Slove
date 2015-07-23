//
//  SLVTools.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVTools.h"

@implementation SLVTools

+ (NSString *)createFolder:(NSString *)folderName {
	if (!folderName) {
		SLVLog(@"[%@] No folder name defined", self.class);
		return nil;
	}
	NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:path
									   withIntermediateDirectories:NO
														attributes:nil
															 error:&error]) {
			SLVLog(@"[%@] Create directory error: %@", self.class, error);
		}
	}
	path = [[paths objectAtIndex:0] stringByAppendingPathComponent:folderName];
	return path;
}

+ (BOOL)containsSpecialCharacters:(NSString *)string {
	NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
	NSRange range = [string rangeOfCharacterFromSet:illegalFileNameCharacters];
	if (range.location != NSNotFound) {
		return YES;
	} else {
		return NO;
	}
}

+ (NSString *)generateId {
	return [[NSString stringWithFormat:@"%f", CACurrentMediaTime()] MD5];
}

+ (NSString*)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)removeFile:(NSString *)fileName {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
	NSError *error;
	if (![fileManager removeItemAtPath:filePath error:&error]) {
		SLVLog(@"[%@] Could not delete file %@", self.class, [error localizedDescription]);
	}
}

@end
