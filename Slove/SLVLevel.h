//
//  SLVLevel.h
//  Slove
//
//  Created by Guillaume Bellut on 14/10/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SLVLevel : JSONModel

@property (nonatomic) int number;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIImage *picture;

@end
