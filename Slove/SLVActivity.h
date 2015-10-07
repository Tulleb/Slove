//
//  SLVActivity.h
//  Slove
//
//  Created by Guillaume Bellut on 04/10/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "JSONModel.h"

@interface SLVActivity : JSONModel

typedef enum : NSInteger {
	kSloved,
	kLevel,
	kJoined,
	kCredit
} ActivityType;

@property (nonatomic) BOOL isNew;
@property (nonatomic) ActivityType type;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString<Optional> *relatedUser;
@property (nonatomic, strong) NSNumber<Optional> *value;

@end
