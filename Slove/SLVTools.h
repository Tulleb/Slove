//
//  SLVTools.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVTools : NSObject

+ (NSString *)createFolder:(NSString *)folderName;
+ (BOOL)containsSpecialCharacters:(NSString *)string;
+ (NSString *)generateId;
+ (NSString*)applicationDocumentsDirectory;
+ (void)removeFile:(NSString *)fileName;
+ (void)saveImage:(UIImage *)image withName:(NSString *)name; // Try to use SDWebImage instead
+ (UIImage *)loadImageWithName:(NSString *)name; // Try to use SDWebImage instead
+ (NSString *)trimUsername:(NSString *)username;
+ (NSString *)validateUsername:(NSString *)username;
+ (NSString *)usernameIsFilled:(NSString *)username;
+ (NSString *)usernameSize:(NSString *)username;
+ (NSString *)usernameIsValid:(NSString *)username;
+ (NSString *)usernameIsFree:(NSString *)username;
+ (NSString *)validateEmail:(NSString *)email;
+ (NSString *)emailIsFilled:(NSString *)email;
+ (NSString *)emailIsValid:(NSString *)email;
+ (NSString *)emailIsFree:(NSString *)email;
+ (NSString *)validatePassword:(NSString *)password;
+ (NSString *)passwordIsFilled:(NSString *)password;
+ (NSString *)passwordSize:(NSString *)password;
+ (NSString *)validateConditions:(BOOL)conditions;
+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber withCountryCodeData:(SLVCountryCodeData *)countryCodeData;
+ (BOOL)checkConnection;
+ (void)playSound:(NSString *)soundName;
+ (BOOL)isSameDay:(NSDate*)date1 thatDay:(NSDate*)date2;
+ (BOOL)deviceIs24Hour;
+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

@end
