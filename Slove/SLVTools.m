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
	if (![self usernameIsFilled:username]) {
		return @"Your username is empty";
	}
	
	if (![self usernameSize:username]) {
		return [NSString stringWithFormat:@"Your username must contains between %d and %d characters", VALIDATION_USERNAME_MIN_LENGTH, VALIDATION_USERNAME_MAX_LENGTH];
	}
	
	if (![self usernameIsValid:username]) {
		return @"Your username can only contains alphanumerical and _ characters";
	}
	
	if (![self usernameIsFree:username]) {
		return @"This username already exists";
	}
	
	return VALIDATION_ANSWER_KEY;
}

+ (BOOL)usernameIsFilled:(NSString *)username {
	return (username && ![username isEqualToString:@""]);
}

+ (BOOL)usernameSize:(NSString *)username {
	return ([username length] >= VALIDATION_USERNAME_MIN_LENGTH && [username length] <= VALIDATION_USERNAME_MAX_LENGTH);
}

+ (BOOL)usernameIsValid:(NSString *)username {
	NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:USERNAME_ACCEPTED_CHARACTERS];
	return [[username stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
}

+ (BOOL)usernameIsFree:(NSString *)username {
	PFQuery *query = [PFUser query];
	[query whereKey:@"username" equalTo:username];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users named %@", SLV_WARNING, (unsigned long)[foundUsers count], username);
		return NO;
	}
	
	return YES;
}

+ (NSString *)validateEmail:(NSString *)email {
	if (![self emailIsFilled:email]) {
		return @"Your email is empty";
	}
	
	if (![self emailIsValid:email]) {
		return @"Your email is invalid";
	}
	
	if (![self emailIsFree:email]) {
		return @"This email already exists";
	}
	
	return VALIDATION_ANSWER_KEY;
}

+ (BOOL)emailIsFilled:(NSString *)email {
	return (email && ![email isEqualToString:@""]);
}

+ (BOOL)emailIsValid:(NSString *)email {
	BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
	NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:email];
}

+ (BOOL)emailIsFree:(NSString *)email {
	PFQuery *query = [PFUser query];
	[query whereKey:@"email" equalTo:email];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users with email %@", SLV_WARNING, (unsigned long)[foundUsers count], email);
		return NO;
	}
	
	return YES;
}

+ (NSString *)validatePassword:(NSString *)password {
	if (![self passwordIsFilled:password]) {
		return @"Your password is empty";
	}
	
	if (![self passwordSize:password]) {
		return [NSString stringWithFormat:@"Your password must contains between %d and %d characters", VALIDATION_PASSWORD_MIN_LENGTH, VALIDATION_PASSWORD_MAX_LENGTH];
	}
	
	return VALIDATION_ANSWER_KEY;
}

+ (BOOL)passwordIsFilled:(NSString *)password {
	return (password && ![password isEqualToString:@""]);
}

+ (BOOL)passwordSize:(NSString *)password {
	return ([password length] >= VALIDATION_PASSWORD_MIN_LENGTH && [password length] <= VALIDATION_PASSWORD_MAX_LENGTH);
}

+ (NSString *)validateConditions:(BOOL)conditions {
	if (!conditions) {
		return @"You must accept our terms of service to continue";
	}
	
	return VALIDATION_ANSWER_KEY;
}

@end
