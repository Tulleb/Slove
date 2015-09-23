//
//  SLVAddSloverViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 23/09/2015.
//  Copyright © 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVAddSloverViewController.h"
#import "SLVContactTableViewCell.h"

@interface SLVAddSloverViewController ()

@end

@implementation SLVAddSloverViewController

- (void)viewDidLoad {
	self.appName = @"add_slover";
	
    [super viewDidLoad];
	
	self.searchView.backgroundColor = BLUE;
	
	self.searchTextField.background = [UIImage imageNamed:@"Assets/Box/input_repertoire"];
	self.searchTextField.textColor = BLUE;
	
	self.searchImageView.image = [UIImage imageNamed:@"Assets/Image/loupe"];
	
	[self initTapToDismiss];
	
	[self loadBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.searchTextField becomeFirstResponder];
}

- (void)initTapToDismiss {
	UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
										   initWithTarget:self
										   action:@selector(hideKeyboard)];
	
	[self.view addGestureRecognizer:tapGesture];
}

- (void)hideKeyboard {
	for (UITextField *textField in self.searchView.subviews) {
		[textField resignFirstResponder];
	}
}

- (void)lookForSloversContaining:(NSString *)name {
	[self.loadingIndicator startAnimating];
	
	if (name) {
		PFQuery *query = [PFUser query];
		[query whereKey:@"username" containsString:name];
		NSArray *foundUsers = [query findObjects];
		
		if (foundUsers && [foundUsers count] > 0) {
			SLVLog(@"Retrieved %lu username containing %@", (unsigned long)[foundUsers count], name);
			
			NSMutableArray *foundContacts = [[NSMutableArray alloc] init];
			
			for (PFUser *user in foundUsers) {
				SLVContact *contact = [[SLVContact alloc] init];
				
				contact.username = [user objectForKey:@"username"];
				
				NSString *pictureUrl = [user objectForKey:@"pictureUrl"];
				if (pictureUrl) {
					contact.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
				} else {
					contact.picture = [UIImage imageNamed:@"Assets/Avatar/avatar_user"];
				}
				
				NSString *fullName = @"";
				NSString *firstName = [user objectForKey:@"firstName"];
				
				if (firstName) {
					fullName = [fullName stringByAppendingString:firstName];
				}
				
				NSString *lastName = [user objectForKey:@"lastName"];
				
				if (lastName) {
					if (![fullName isEqualToString:@""]) {
						fullName = [fullName stringByAppendingString:@" "];
					}
					
					fullName = [fullName stringByAppendingString:lastName];
				}
				
				contact.fullName = fullName;
				
				[foundContacts addObject:contact];
			}
			
			self.sloversFound = [NSArray arrayWithArray:foundContacts];
			
			[self.sloverTableView reloadData];
			
			[self.sloverTableView showByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
		} else {
			[self.sloverTableView hideByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
		}
	}
	
	[self.loadingIndicator stopAnimating];
}

- (void)followSlover:(UIButton *)button {
	SLVContact *contact = [self.sloversFound objectAtIndex:button.tag];
	NSString *username = contact.username;
	
	[PFCloud callFunctionInBackground:FOLLOW_SLOVER_FUNCTION
					   withParameters:@{@"username" : username}
								block:^(id object, NSError *error){
									if (!error) {
										NSString *popupBodySloverFollowed = NSLocalizedString(@"popup_body_slover_followed", nil);
										
										popupBodySloverFollowed = [popupBodySloverFollowed stringByReplacingOccurrencesOfString:@"[username]"
																			 withString:username];
										
										self.followedPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_success", nil) body:popupBodySloverFollowed buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_ok", nil), nil] andDismissButton:NO];
										
										self.followedPopup.delegate = self;
										
										[self.navigationController presentViewController:self.followedPopup animated:YES completion:nil];
									} else {
										SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(error.localizedDescription, nil) buttonsTitle:nil andDismissButton:YES];
										
										[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
										
										SLVLog(@"%@%@", SLV_ERROR, error.description);
										[ParseErrorHandlingController handleParseError:error];
									}
								}];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[self lookForSloversContaining:textField.text];
	
	return YES;
}


#pragma mark - SLVInteractionPopupDelegate

- (void)soloButtonPressed:(SLVInteractionPopupViewController *)popup {
	if (popup == self.followedPopup) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.sloversFound count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"NewSloverContactCell";
	SLVContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	if (!cell) {
		[tableView registerNib:[UINib nibWithNibName:@"SLVContactTableViewCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
		cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.subtitleImageView.image = [UIImage imageNamed:@"Assets/Image/coeur_rouge"];
	[cell.selectionButton setBackgroundImage:[UIImage imageNamed:@"Assets/Button/bt_ajout_contact"] forState:UIControlStateNormal];
	cell.subtitleLabel.textColor = BLUE;
	cell.selectionButton.tag = indexPath.row;
	[cell.selectionButton addTarget:self action:@selector(followSlover:) forControlEvents:UIControlEventTouchUpInside];
	
	SLVContact *contact = [self.sloversFound objectAtIndex:indexPath.row];
	
	cell.titleLabel.text = contact.username;
	
	cell.subtitleLabel.text = contact.fullName;
	
	cell.pictureImageView.image = contact.picture;
	cell.pictureImageView.contentMode = UIViewContentModeScaleAspectFill;
	cell.pictureImageView.clipsToBounds = YES;
	
	cell.layerImageView.image = [UIImage imageNamed:@"Assets/Layer/masque_profil_repertoire"];
	
	[SLVViewController setStyle:cell];
	
	cell.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE_LARGE];
	
	cell.subtitleLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT size:DEFAULT_FONT_SIZE];
	
	return cell;
}

@end
