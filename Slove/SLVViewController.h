//
//  SLVViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
	kBackToPrevious,
	kBackToRoot
} BackButtonType;

@interface SLVViewController : UIViewController

@property (nonatomic, strong) NSString * appName;
@property (nonatomic) BackButtonType backButtonType;

+ (void)setStyle:(UIView *)view;
- (void)loadBackButton;

@end
