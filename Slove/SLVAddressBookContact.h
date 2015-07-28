//
//  SLVAddressBookContact.h
//  Slove
//
//  Created by Guillaume Bellut on 28/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLVAddressBookContact : NSObject

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) UIImage *picture;

@end
