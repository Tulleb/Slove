//
//  SLVViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVViewController : UIViewController

@property (nonatomic, strong) NSString * appName;

+ (void)setStyle:(UIView *)view;
- (void)loadBackButton;
- (void)goBack:(id)sender;
- (void)goToHome;

@end
