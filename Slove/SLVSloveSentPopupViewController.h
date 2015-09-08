//
//  SLVSloveSentPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 01/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"

@interface SLVSloveSentPopupViewController : SLVPopupViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleLabelTopLayoutConstraint;

@end
