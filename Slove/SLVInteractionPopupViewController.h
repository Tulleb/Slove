//
//  SLVInteractionPopupViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 16/08/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVPopupViewController.h"

@protocol InteractionPopupDelegate <NSObject>

- (void)soloButtonPressed:(id)sender;
- (void)buttonAPressed:(id)sender;
- (void)buttonBPressed:(id)sender;

@end


@interface SLVInteractionPopupViewController : SLVPopupViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UIButton *soloButton;
@property (strong, nonatomic) IBOutlet UIButton *buttonA;
@property (strong, nonatomic) IBOutlet UIButton *buttonB;

- (id)initWithTitle:(NSString *)title body:(NSString *)body andButtonsTitle:(NSArray *)buttonTitles;
- (IBAction)soloButtonAction:(id)sender;
- (IBAction)buttonAAction:(id)sender;
- (IBAction)buttonBAction:(id)sender;

@end
