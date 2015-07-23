//
//  Route.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "ActiveBaseRecord.h"

@interface Route : ActiveBaseRecord

@property (nonatomic, strong) NSString *stringURL;
@property (nonatomic, strong) NSString *method;

@end
