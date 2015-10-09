//
//  AppDelegate.h
//  Slove
//
//  Created by Guillaume Bellut on 19/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

- (void)hideByFadingWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;
- (void)showByFadingWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;

- (void)hideByZoomingInWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;
- (void)showByZoomingInWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;

- (void)hideByZoomingOutWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;
- (void)showByZoomingOutWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock;

@end
