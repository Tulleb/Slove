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
+ (NSString *)trimUsername:(NSString *)username;
+ (NSString *)validateUsername:(NSString *)username;
+ (NSString *)validateEmail:(NSString *)email;
+ (NSString *)validatePassword:(NSString *)password;
+ (NSString *)validateConditions:(BOOL)conditions;

@end
