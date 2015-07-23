//
//  SLVLogger.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVLogger : NSObject

+ (SLVLogger *)sharedStore;

- (void)logFile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;

@end
