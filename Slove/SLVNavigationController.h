//
//  SLVNavigationController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CustomBadge/CustomBadge.h>
#import "SLVProfileViewController.h"
#import <Google/Analytics.h>

@interface SLVNavigationController : UINavigationController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *loaderImageView;
@property (strong, nonatomic) UIView *bottomNavigationBarView;
@property (strong, nonatomic) UIView *sloveView;
@property (strong, nonatomic) UIButton *sloveButton;
@property (strong, nonatomic) CustomBadge *activityCounterBadge;
@property (strong, nonatomic) CustomBadge *sloveCounterBadge;
@property (strong, nonatomic) UIButton *activityButton;
@property (strong, nonatomic) UIButton *profileButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) NSLayoutConstraint *sloveViewConstraint;
@property (strong, nonatomic) NSLayoutConstraint *sloveBadgeConstraint;
@property (strong, nonatomic) NSLayoutConstraint *activityBadgeConstraint;
@property (nonatomic) BOOL sloveViewIsMoved;
@property (nonatomic, strong) NSTimer *sloveClickTimer;
@property (nonatomic, strong) NSTimer *sloveLastClickTimer;
@property (nonatomic) float sloveClickDuration;
@property (nonatomic) float sloveClickDecelerationDuration;
@property (nonatomic) BOOL firstLoad;
@property (nonatomic, strong) id<GAITracker> tracker;

- (void)activityAction:(id)sender;
- (void)sloveAction:(id)sender;
- (void)profileAction:(id)sender;
- (void)hideBottomNavigationBar;
- (void)showBottomNavigationBar;
- (void)refreshSloveCounter;
- (void)refreshActivityCounter;
- (void)goToHome;
- (void)sloveLongPress:(UILongPressGestureRecognizer *)gesture;

@end
