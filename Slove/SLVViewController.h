//
//  SLVViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "Amplitude.h"

@interface SLVViewController : UIViewController

@property (nonatomic, strong) NSString * appName;
@property (nonatomic, strong) id<GAITracker> tracker;

+ (void)setStyle:(UIView *)view;
- (void)loadBackButton;
- (void)loadLogoutButton;
- (void)goToHome;

// Subclassed method
- (void)animateImages;

@end
