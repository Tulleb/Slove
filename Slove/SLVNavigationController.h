//
//  SLVNavigationController.h
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVNavigationController : UINavigationController

@property (strong, nonatomic) IBOutlet UIView *bottomNavigationBarView;
@property (strong, nonatomic) IBOutlet UIButton *activityButton;
@property (strong, nonatomic) IBOutlet UIButton *sloveButton;
@property (strong, nonatomic) IBOutlet UIButton *profileButton;

- (IBAction)activityAction:(id)sender;
- (IBAction)sloveAction:(id)sender;
- (IBAction)profileAction:(id)sender;

@end
