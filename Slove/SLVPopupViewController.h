//
//  SLVPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 16/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"


typedef enum : NSInteger {
	kPriorityLow,
	kPriorityMedium,
	kPriorityHigh
} PriorityType;

@interface SLVPopupViewController : SLVViewController

@property (nonatomic) BOOL isRemanent;
@property (nonatomic) PriorityType priority;

@end
