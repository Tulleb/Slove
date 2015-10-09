//
//  AppDelegate.h
//  Slove
//
//  Created by Guillaume Bellut on 19/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

#define ZOOMING_COEFFICIENT	3.0f

#pragma mark - Fading

- (void)hideByFadingWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseIn
					animations:^{
						self.alpha = 0;
					}
					completion:^(BOOL finished){
						self.hidden = YES;
						self.alpha = alphaBuffer;
						if (completionBlock) {
							completionBlock();
						}
					}];
}

- (void)showByFadingWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (!self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	self.alpha = 0;
	self.hidden = NO;
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseOut
					animations:^{
						self.alpha = alphaBuffer;
					}
					completion:^(BOOL finished){
						if (completionBlock) {
							completionBlock();
						}
					}];
}


#pragma mark - Zooming In

- (void)hideByZoomingInWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	CGAffineTransform __block transformBuffer = self.transform;
	
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseIn
					animations:^{
						self.alpha = 0;
						self.transform = CGAffineTransformScale(self.transform, 1 * ZOOMING_COEFFICIENT, 1 * ZOOMING_COEFFICIENT);
					}
					completion:^(BOOL finished){
						self.hidden = YES;
						self.alpha = alphaBuffer;
						self.transform = transformBuffer;
						if (completionBlock) {
							completionBlock();
						}
					}];
}

- (void)showByZoomingInWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (!self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	self.alpha = 0;
	self.hidden = NO;
	CGAffineTransform __block transformBuffer = self.transform;
	self.transform = CGAffineTransformScale(self.transform, 1 / ZOOMING_COEFFICIENT, 1 / ZOOMING_COEFFICIENT);
	
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseOut
					animations:^{
						self.alpha = alphaBuffer;
						self.transform = transformBuffer;
					}
					completion:^(BOOL finished){
						if (completionBlock) {
							completionBlock();
						}
					}];
}


#pragma mark - Zooming Out

- (void)hideByZoomingOutWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	CGAffineTransform __block transformBuffer = self.transform;
	
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseIn
					animations:^{
						self.alpha = 0;
						self.transform = CGAffineTransformScale(self.transform, 1 / ZOOMING_COEFFICIENT, 1 / ZOOMING_COEFFICIENT);
					}
					completion:^(BOOL finished){
						self.hidden = YES;
						self.alpha = alphaBuffer;
						self.transform = transformBuffer;
						if (completionBlock) {
							completionBlock();
						}
					}];
}

- (void)showByZoomingOutWithDuration:(NSTimeInterval)duration AndCompletion:(void (^)())completionBlock
{
	if (!self.hidden) {
		return;
	}
	
	int alphaBuffer = self.alpha;
	self.alpha = 0;
	self.hidden = NO;
	CGAffineTransform __block transformBuffer = self.transform;
	self.transform = CGAffineTransformScale(self.transform, 1 * ZOOMING_COEFFICIENT, 1 * ZOOMING_COEFFICIENT);
	
	[UIView transitionWithView:self
					  duration:duration
					   options:UIViewAnimationOptionCurveEaseOut
					animations:^{
						self.alpha = alphaBuffer;
						self.transform = transformBuffer;
					}
					completion:^(BOOL finished){
						if (completionBlock) {
							completionBlock();
						}
					}];
}

@end
