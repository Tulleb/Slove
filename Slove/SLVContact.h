//
//  SLVContact.h
//  Slove
//
//  Created by Guillaume Bellut on 28/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "SLVLevel.h"

@interface SLVContact : JSONModel

@property (nonatomic, strong) NSString<Optional> *phoneNumber;
@property (nonatomic, strong) NSString<Optional> *fullName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSURL<Optional> *pictureUrl;
@property (nonatomic, strong) NSNumber<Optional> *sloveCounter;
@property (nonatomic, strong) SLVLevel<Optional> *currentLevel;

@end
