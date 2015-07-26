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


#pragma mark - Field validation

+ (NSString *)trimUsername:(NSString *)username {
	return [username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (NSString *)validateUsername:(NSString *)username {
	NSString *validationString;
	
	validationString = [self usernameIsFilled:username];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self usernameSize:username];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self usernameIsValid:username];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self usernameIsFree:username];
	if (validationString) {
		return validationString;
	}
	
	return nil;
}

+ (NSString *)usernameIsFilled:(NSString *)username {
	if (username && ![username isEqualToString:@""]) {
		return nil;
	} else {
		return @"Your username is empty";
	}
}

+ (NSString *)usernameSize:(NSString *)username {
	if ([username length] >= VALIDATION_USERNAME_MIN_LENGTH && [username length] <= VALIDATION_USERNAME_MAX_LENGTH) {
		return nil;
	} else {
		return [NSString stringWithFormat:@"Your username must contains between %d and %d characters", VALIDATION_USERNAME_MIN_LENGTH, VALIDATION_USERNAME_MAX_LENGTH];
	}
}

+ (NSString *)usernameIsValid:(NSString *)username {
	NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:USERNAME_ACCEPTED_CHARACTERS];
	if ([[username stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""]) {
		return nil;
	} else {
		return @"Your username can only contains lower alphanumerical and _ characters";
	}
}

+ (NSString *)usernameIsFree:(NSString *)username {
	PFQuery *query = [PFUser query];
	[query whereKey:@"username" equalTo:username];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users named %@", SLV_WARNING, (unsigned long)[foundUsers count], username);
		return @"This username already exists";
	}
	
	return nil;
}

+ (NSString *)validateEmail:(NSString *)email {
	NSString *validationString;
	
	validationString = [self emailIsFilled:email];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self emailIsValid:email];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self emailIsFree:email];
	if (validationString) {
		return validationString;
	}
	
	return nil;
}

+ (NSString *)emailIsFilled:(NSString *)email {
	if (email && ![email isEqualToString:@""]) {
		return nil;
	} else {
		return @"Your email is empty";
	}
}

+ (NSString *)emailIsValid:(NSString *)email {
	BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
	NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	if ([emailTest evaluateWithObject:email]) {
		return nil;
	} else {
		return @"Your email is invalid";
	}
}

+ (NSString *)emailIsFree:(NSString *)email {
	PFQuery *query = [PFUser query];
	[query whereKey:@"email" equalTo:email];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users with email %@", SLV_WARNING, (unsigned long)[foundUsers count], email);
		return @"This email already exists";
	}
	
	return nil;
}

+ (NSString *)validatePassword:(NSString *)password {
	NSString *validationString;
	
	validationString = [self passwordIsFilled:password];
	if (validationString) {
		return validationString;
	}
	
	validationString = [self passwordSize:password];
	if (validationString) {
		return validationString;
	}
	
	return nil;
}

+ (NSString *)passwordIsFilled:(NSString *)password {
	if (password && ![password isEqualToString:@""]) {
		return nil;
	} else {
		return @"Your password is empty";
	}
}

+ (NSString *)passwordSize:(NSString *)password {
	if ([password length] >= VALIDATION_PASSWORD_MIN_LENGTH && [password length] <= VALIDATION_PASSWORD_MAX_LENGTH) {
		return nil;
	} else {
		return [NSString stringWithFormat:@"Your password must contains between %d and %d characters", VALIDATION_PASSWORD_MIN_LENGTH, VALIDATION_PASSWORD_MAX_LENGTH];
	}
}

+ (NSString *)validateConditions:(BOOL)conditions {
	if (!conditions) {
		return @"You must accept our terms of service to continue";
	}
	
	return nil;
}

@end
