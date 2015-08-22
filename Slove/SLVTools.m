//
//  SLVTools.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVTools.h"
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import "SLVCountryCodeData.h"

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

+ (NSString *)applicationDocumentsDirectory {
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

+ (void)saveImage:(UIImage *)image withName:(NSString *)name {
	if (image && name && ![name isEqualToString:@""]) {
		NSString *documentsDirectory = [SLVTools applicationDocumentsDirectory];
		
		NSError *error;
		NSString *folder = [documentsDirectory stringByAppendingPathComponent:@"/cache"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:&error];
			
			if (error) {
				SLVLog(@"%@%@", SLV_ERROR, error.description);
			}
		}
		
		NSString *path = [folder stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", name]];
		NSData *data = UIImagePNGRepresentation(image);
		[data writeToFile:path atomically:YES];
	} else {
		SLVLog(@"%@Trying to save an empty image or an image without name", SLV_WARNING);
	}
}

+ (UIImage *)loadImageWithName:(NSString *)name {
	if (name && ![name isEqualToString:@""]) {
		NSString *documentsDirectory = [SLVTools applicationDocumentsDirectory];
		NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cache/%@", name]];
		UIImage* image = [UIImage imageWithContentsOfFile:path];
		return image;
	} else {
		SLVLog(@"%@Trying to load an image without name", SLV_WARNING);
		return nil;
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
		return @"error_username_empty";
	}
}

+ (NSString *)usernameSize:(NSString *)username {
	if ([username length] >= VALIDATION_USERNAME_MIN_LENGTH && [username length] <= VALIDATION_USERNAME_MAX_LENGTH) {
		return nil;
	} else {
		return @"error_username_length";
	}
}

+ (NSString *)usernameIsValid:(NSString *)username {
	NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:USERNAME_ACCEPTED_CHARACTERS];
	if ([[username stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""]) {
		return nil;
	} else {
		return @"error_username_characters";
	}
}

+ (NSString *)usernameIsFree:(NSString *)username {
	PFQuery *query = [PFUser query];
	[query whereKey:@"username" equalTo:username];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users named %@", SLV_WARNING, (unsigned long)[foundUsers count], username);
		return @"error_username_taken";
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
		return @"error_email_empty";
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
		return @"error_email_invalid";
	}
}

+ (NSString *)emailIsFree:(NSString *)email {
	PFQuery *query = [PFUser query];
	[query whereKey:@"email" equalTo:email];
	NSArray *foundUsers = [query findObjects];
	
	if (foundUsers && [foundUsers count] > 0) {
		SLVLog(@"%@Retrieved %lu users with email %@", SLV_WARNING, (unsigned long)[foundUsers count], email);
		return @"error_email_taken";
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
		return @"error_password_empty";
	}
}

+ (NSString *)passwordSize:(NSString *)password {
	if ([password length] >= VALIDATION_PASSWORD_MIN_LENGTH && [password length] <= VALIDATION_PASSWORD_MAX_LENGTH) {
		return nil;
	} else {
		return @"error_password_length";
	}
}

+ (NSString *)validateConditions:(BOOL)conditions {
	if (!conditions) {
		return @"error_accept_conditions";
	}
	
	return nil;
}

+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber withCountryCodeData:(SLVCountryCodeData *)countryCodeData {
	NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
	NSError *error = nil;
	NBPhoneNumber *myNumber;
	
	if (countryCodeData) {
		myNumber = [phoneUtil parse:phoneNumber defaultRegion:countryCodeData.ISOCode error:&error];
	} else {
		myNumber = [phoneUtil parse:phoneNumber defaultRegion:nil error:&error];
	}
	
	if (error) {
		return @"error_phone_number_format";
	}
	
	return [phoneUtil format:myNumber numberFormat:NBEPhoneNumberFormatE164 error:&error];
}

+ (BOOL)checkConnection {
	return NO;
}

+ (void)playSound:(NSString *)soundName {
	NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], soundName];
	NSURL *soundUrl = [NSURL fileURLWithPath:path];
	
	AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
	[audioPlayer play];
	SLVLog(@"Playing sound: %@", CONNECTION_VIEW_SOUND);
}

@end
