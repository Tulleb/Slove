//
//  SLVNavigationController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVNavigationController : UINavigationController

@property (strong, nonatomic) UIView *bottomNavigationBarView;
@property (strong, nonatomic) UIButton *activityButton;
@property (strong, nonatomic) UIButton *sloveButton;
@property (strong, nonatomic) UIButton *profileButton;

- (void)activityAction:(id)sender;
- (void)sloveAction:(id)sender;
- (void)profileAction:(id)sender;

@end
