//
//  SLVFacebookFriend.h
//  Slove
//
//  Created by Guillaume Bellut on 06/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVContact.h"

@interface SLVFacebookFriend : SLVContact

@property (nonatomic, strong) NSString *facebookId;
@property (nonatomic, strong) NSString *pictureURLString;
@property (nonatomic) BOOL pictureDownloaded;

@end
