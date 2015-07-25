//
//  SLVNetworking.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "TimeoutAFHTTPRequestSerializer.h"
#import "SLVRoute.h"


@protocol MEPHTTPDelegate <NSObject>

- (void)requestFinished:(AFHTTPRequestOperation *)request withResponseObject:(id)responseObject parameters:(NSDictionary *)params andFiles:(NSArray *)files;
- (void)requestFailed:(AFHTTPRequestOperation *)request withError:(NSError *)error parameters:(NSDictionary *)params andFiles:(NSArray *)files;

@end


@interface SLVNetworking : NSObject

- (AFHTTPRequestOperation *)executeRequestWithRoute:(SLVRoute *)route parameters:(NSDictionary *)parameters files:(NSArray *)files contentTypes:(NSSet *)contentTypes andDelegate:(id<MEPHTTPDelegate>)delegate;

@end
