//
//  SLVInteractionPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 16/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"
@class SLVInteractionPopupViewController;

@protocol SLVInteractionPopupDelegate <NSObject>

@optional
- (void)soloButtonPressed:(SLVInteractionPopupViewController *)popup;
- (void)buttonAPressed:(SLVInteractionPopupViewController *)popup;
- (void)buttonBPressed:(SLVInteractionPopupViewController *)popup;
- (void)dismissButtonPressed:(SLVInteractionPopupViewController *)popup;

@end


@interface SLVInteractionPopupViewController : SLVPopupViewController

@property (strong, nonatomic) id<SLVInteractionPopupDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UIImageView *popupImageView;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rightBorderConstraint;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UIButton *soloButton;
@property (strong, nonatomic) IBOutlet UIButton *buttonA;
@property (strong, nonatomic) IBOutlet UIButton *buttonB;
@property (strong, nonatomic) NSString *popupTitle;
@property (strong, nonatomic) NSString *popupBody;
@property (strong, nonatomic) NSArray *buttonTitles;
@property (nonatomic) BOOL dismissShouldDisplayed;

- (id)initWithTitle:(NSString *)title body:(NSString *)body buttonsTitle:(NSArray *)buttonTitles andDismissButton:(BOOL)dismissShouldDisplayed;
- (IBAction)soloButtonAction:(id)sender;
- (IBAction)buttonAAction:(id)sender;
- (IBAction)buttonBAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end
