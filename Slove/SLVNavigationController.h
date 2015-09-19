//
//  SLVNavigationController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CustomBadge/CustomBadge.h>
#import "SLVSettingsViewController.h"

@interface SLVNavigationController : UINavigationController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *loaderImageView;
@property (strong, nonatomic) UIView *bottomNavigationBarView;
@property (strong, nonatomic) UIView *sloveView;
@property (strong, nonatomic) UIButton *sloveButton;
@property (strong, nonatomic) CustomBadge *sloveCounterBadge;
@property (strong, nonatomic) UIButton *activityButton;
@property (strong, nonatomic) UIButton *settingsButton;
@property (strong, nonatomic) UIButton *homeButton;
@property (strong, nonatomic) NSLayoutConstraint *sloveViewConstraint;
@property (strong, nonatomic) NSLayoutConstraint *sloveBadgeConstraint;
@property (nonatomic) BOOL sloveViewIsMoved;
@property (nonatomic, strong) NSTimer *sloveClickTimer;
@property (nonatomic) float sloveClickDuration;

- (void)activityAction:(id)sender;
- (void)sloveAction:(id)sender;
- (void)settingsAction:(id)sender;
- (void)hideBottomNavigationBar;
- (void)showBottomNavigationBar;
- (void)refreshSloveCounter;
- (void)goToHome;
- (void)sloveLongPress:(UILongPressGestureRecognizer *)gesture;

@end
