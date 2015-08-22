//
//  SLVNavigationController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CustomBadge/CustomBadge.h>

@interface SLVNavigationController : UINavigationController

@property (strong, nonatomic) UIView *bottomNavigationBarView;
@property (strong, nonatomic) UIButton *activityButton;
@property (strong, nonatomic) UIView *sloveView;
@property (strong, nonatomic) UIButton *sloveButton;
@property (strong, nonatomic) CustomBadge *sloveCounterBadge;
@property (strong, nonatomic) UIButton *profileButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) NSLayoutConstraint *sloveViewConstraint;
@property (strong, nonatomic) NSLayoutConstraint *sloveBadgeConstraint;
@property (nonatomic) BOOL sloveViewIsMoved;

- (void)activityAction:(id)sender;
- (void)sloveAction:(id)sender;
- (void)profileAction:(id)sender;
- (void)hideBottomNavigationBar;
- (void)showBottomNavigationBar;
- (void)refreshSloveCounter;

@end
