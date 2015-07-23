//
//  User.h
//  Slove
//
//  Created by Guillaume Bellut on 23/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "ActiveBaseRecord.h"

@interface User : ActiveBaseRecord

@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *phoneNumber;

@end
