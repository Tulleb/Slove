//
//  SLVNetworking.m
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVNetworking.h"

@implementation SLVNetworking

- (AFHTTPRequestOperation *)executeRequestWithRoute:(Route *)route parameters:(NSDictionary *)parameters files:(NSArray *)files contentTypes:(NSSet *)contentTypes andDelegate:(id<MEPHTTPDelegate>)delegate {
	NSURL *baseURL = [NSURL URLWithString:SERVER_ADDRESS];
	NSURL *url = [NSURL URLWithString:route.stringURL relativeToURL:baseURL];
	
	AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
	[manager setRequestSerializer:[TimeoutAFHTTPRequestSerializer serializer]];
	
	AFHTTPRequestOperation *request = nil;
	
	if (contentTypes) {
		manager.responseSerializer.acceptableContentTypes = contentTypes;
	}
	
	if (route.method) {
		if ([route.method isEqualToString:@"GET"]) {
			__block NSDictionary *blockParams = parameters;
			__block NSArray *blockFiles = files;
			request = [manager GET:[url absoluteString] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
				SLVLog(@"Request '%@' succeed", route.stringURL);
				
				if ([delegate respondsToSelector:@selector(requestFinished:withResponseObject:parameters:andFiles:)]) {
					[delegate requestFinished:operation withResponseObject:responseObject parameters:blockParams andFiles:blockFiles];
				}
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				SLVLog(@"%@Request '%@' failed with error: %@", LOG_ERROR, route.stringURL, error);
				
				if ([delegate respondsToSelector:@selector(requestFailed:withError:parameters:andFiles:)]) {
					[delegate requestFailed:operation withError:error parameters:blockParams andFiles:blockFiles];
				}
			}];
		}
		else if ([route.method isEqualToString:@"POST"]) {
			__block NSDictionary *blockParams = parameters;
			__block NSArray *blockFiles = files;
			request = [manager POST:[url absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
				for (NSDictionary *dic in files) {
					if ([dic objectForKey:@"path"] && [dic objectForKey:@"name"]) {
						NSError *error;
						NSURL *pathURL = [NSURL fileURLWithPath:[dic objectForKey:@"path"]];
						
						[formData appendPartWithFileURL:pathURL name:[dic objectForKey:@"name"] error:&error];
						
						if (error) {
							SLVLog(@"%@Failed to add file '%@' with name '%@': %@", LOG_ERROR, [dic objectForKey:@"path"], [dic objectForKey:@"name"], error);
						}
					}
				}
			} success:^(AFHTTPRequestOperation *operation, id responseObject) {
				SLVLog(@"Request '%@' succeed", route.stringURL);
				
				if ([delegate respondsToSelector:@selector(requestFinished:withResponseObject:parameters:andFiles:)]) {
					[delegate requestFinished:operation withResponseObject:responseObject parameters:blockParams andFiles:blockFiles];
				}
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				SLVLog(@"%@Request '%@' failed with error: %@", LOG_ERROR, route.stringURL, error);
				
				if ([delegate respondsToSelector:@selector(requestFailed:withError:parameters:andFiles:)]) {
					[delegate requestFailed:operation withError:error parameters:blockParams andFiles:blockFiles];
				}
			}];
		}
		else if ([route.method isEqualToString:@"DELETE"]) {
			__block NSDictionary *blockParams = parameters;
			__block NSArray *blockFiles = files;
			request = [manager DELETE:[url absoluteString] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
				SLVLog(@"Request '%@' succeed", route.stringURL);
				
				if ([delegate respondsToSelector:@selector(requestFinished:withResponseObject:parameters:andFiles:)]) {
					[delegate requestFinished:operation withResponseObject:responseObject parameters:blockParams andFiles:blockFiles];
				}
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				SLVLog(@"%@Request '%@' failed with error: %@", LOG_ERROR, route.stringURL, error);
				
				if ([delegate respondsToSelector:@selector(requestFailed:withError:parameters:andFiles:)]) {
					[delegate requestFailed:operation withError:error parameters:blockParams andFiles:blockFiles];
				}
			}];
		} else {
			SLVLog(@"%@Request method '%@' unknown", LOG_ERROR, route.method);
		}
	}
	
	return request;
}

@end
