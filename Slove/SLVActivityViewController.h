//
//  SLVActivityViewController.h
//  Slove
//
//  Created by Guillaume Bellut on 07/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVViewController.h"

@interface SLVActivityViewController : SLVViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (strong, nonatomic) IBOutlet UILabel *bannerLabel;
@property (strong, nonatomic) IBOutlet UITableView *activityTableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *sectionOrder;
@property (strong, nonatomic) NSDictionary *activities;
@property (nonatomic) BOOL isAlreadyLoading;

@end
