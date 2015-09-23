//
//  SLVAddSloverViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 23/09/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"
#import "SLVInteractionPopupViewController.h"

@interface SLVAddSloverViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SLVInteractionPopupDelegate>

@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UIImageView *searchImageView;
@property (strong, nonatomic) IBOutlet UITableView *sloverTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) SLVInteractionPopupViewController *followedPopup;
@property (strong, nonatomic) NSArray *sloversFound;

@end
