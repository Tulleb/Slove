//
//  SLVAddressBookContact.h
//  Slove
//
//  Created by Guillaume Bellut on 01/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVContact.h"

@interface SLVAddressBookContact : SLVContact

@property (nonatomic, strong) NSArray<Optional> *phoneNumbers;

@end
