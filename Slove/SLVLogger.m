//
//  SLVLogger.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVLogger.h"

@implementation SLVLogger

+ (SLVLogger *)sharedStore {
	static SLVLogger *sharedStore = nil;
	if (!sharedStore)
		sharedStore = [[super allocWithZone:nil] init];
	return sharedStore;
}

- (void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ... {
	va_list ap;
	NSString *print,*file;
	
	va_start(ap,format);
	file = [[NSString alloc] initWithBytes:sourceFile
									length:strlen(sourceFile)
								  encoding:NSUTF8StringEncoding];
	print = [[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
	
	NSString *text = [NSString stringWithFormat:@"%s:%d - %@\n", [[file lastPathComponent] UTF8String], lineNumber, print];
	
	NSDate *today = [NSDate date];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
	NSString *dateString = [dateFormat stringFromDate:today];
	NSString *textWithDate = [NSString stringWithFormat:@"%@ %@", dateString, text];
	
	//NSLog handles synchronization issues
	NSLog(@"%@", text);
	
	return;
}

@end
