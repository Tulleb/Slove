//
//  TimeoutAFHTTPRequestSerializer.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "TimeoutAFHTTPRequestSerializer.h"

@implementation TimeoutAFHTTPRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters error:(NSError *__autoreleasing *)error {
	NSMutableURLRequest *request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
	[request setTimeoutInterval:REQUEST_TIMEOUT];
	
	return request;
}

@end
