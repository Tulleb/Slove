//
//  SLVConstructionPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 06/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"

@interface SLVConstructionPopupViewController : SLVPopupViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@end
