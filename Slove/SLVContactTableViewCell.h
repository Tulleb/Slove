//
//  SLVContactTableViewCell.h
//  Slove
//
//  Created by Guillaume Bellut on 28/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVContactTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectionButton;

@end
