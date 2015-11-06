//
//  SLVActivityViewController.m
//  Slove
//
//  Created by Guillaume Bellut on 07/09/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "SLVActivityViewController.h"
#import "SLVActivity.h"
#import "SLVNewActivityTableViewCell.h"
#import "SLVOldActivityTableViewCell.h"
#import "SLVHomeViewController.h"
#import "SLVSlovedPopupViewController.h"
#import "SLVContactViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SLVActivityViewController ()

@end

@implementation SLVActivityViewController

- (void)viewDidLoad {
	self.appName = @"activity";
	
	[super viewDidLoad];
	
	self.bannerImageView.image = [UIImage imageNamed:@"Assets/Banner/activite_banniere"];
	self.bannerLabel.font = [UIFont fontWithName:DEFAULT_FONT_LIGHT_ITALIC size:DEFAULT_FONT_SIZE];
	self.bannerLabel.textColor = WHITE;
	
	self.sectionOrder = [[NSArray alloc] init];
	self.activities = [[NSDictionary alloc] init];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadActivities) forControlEvents:UIControlEventValueChanged];
	[self.activityTableView addSubview:self.refreshControl];
	
	[self loadBackButton];
	[self loadActivities];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)goBack:(id)sender {
	[super goToHome];
}

- (void)loadActivities {
	if (!self.isAlreadyLoading) {
		self.isAlreadyLoading = YES;
		
		self.sectionOrder = nil;
		self.activities = nil;
		
		NSDictionary *params;
		NSDate *lastRefresh = [USER_DEFAULTS objectForKey:KEY_LAST_ACTIVITY_REFRESH];
		
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		[dateFormatter setTimeZone:timeZone];
		
		if (!lastRefresh) {
			params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"dateLastUpdate", nil];
		} else {
			params = [NSDictionary dictionaryWithObjectsAndKeys:[dateFormatter stringFromDate:lastRefresh], @"dateLastUpdate", nil];
		}
		
		[PFCloud callFunctionInBackground:GET_ACTIVITIES
						   withParameters:params
									block:^(id object, NSError *error){
										if (!error) {
											SLVLog(@"Received data from server: %@", object);
											
											NSDictionary *datas = object;
											NSArray *activities = [datas objectForKey:@"activities"];
											
											if (activities && [activities count] > 0) {
												for (NSDictionary *activity in activities) {
													SLVActivity *parsedActivity = [[SLVActivity alloc] init];
													
													NSString *activityType = [activity objectForKey:@"activityType"];
													
													if ([activityType isEqualToString:@"slove"]) {
														parsedActivity.type = kSloved;
													} else if ([activityType isEqualToString:@"credit"]) {
														parsedActivity.type = kCredit;
													} else if ([activityType isEqualToString:@"level"]) {
														parsedActivity.type = kLevel;
													}
													
													parsedActivity.isNew = [[activity objectForKey:@"isNew"] boolValue];
													parsedActivity.createdAt = [dateFormatter dateFromString:[activity objectForKey:@"createdAt"]];
													parsedActivity.value = [activity objectForKey:@"activityValue"];
													parsedActivity.relatedUser = [activity objectForKey:@"relatedUser"];
													
													if ([activities indexOfObject:activity] == 0) {
														parsedActivity.isNew = YES;
													}
													
													BOOL sectionAlreadyExists = NO;
													for (id section in self.sectionOrder) {
														if ([section isKindOfClass:[NSDate class]] && [SLVTools isSameDay:section thatDay:parsedActivity.createdAt]) {
															sectionAlreadyExists = YES;
															
															[self addActivity:parsedActivity ForSection:section toAdd:NO];
															
															break;
														}
													}
													
													if (!sectionAlreadyExists) {
														if (parsedActivity.isNew) {
															[self addActivity:parsedActivity ForSection:@"new" toAdd:NO];
														} else {
															[self addActivity:parsedActivity ForSection:parsedActivity.createdAt toAdd:YES];
														}
													}
												}
											}
											
											[USER_DEFAULTS setObject:[NSDate date] forKey:KEY_LAST_ACTIVITY_REFRESH];
											
											[self.activityTableView reloadData];
											[self.activityTableView showByFadingWithDuration:ANIMATION_DURATION AndCompletion:nil];
										} else {
											SLVInteractionPopupViewController *errorPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(error.localizedDescription, nil) buttonsTitle:nil andDismissButton:YES];
											
											[self.navigationController presentViewController:errorPopup animated:YES completion:nil];
											
											SLVLog(@"%@%@", SLV_ERROR, error.description);
											[ParseErrorHandlingController handleParseError:error];
										}
										
										[self.activityIndicatorView stopAnimating];
										
										if ([self.refreshControl isRefreshing]) {
											[self.refreshControl endRefreshing];
										}
										
										self.isAlreadyLoading = NO;
									}];
	}
}

- (void)addActivity:(SLVActivity *)activity ForSection:(id)section toAdd:(BOOL)shouldAddSectionToSectionOrder {
	NSMutableArray *sectionActivities = [[NSMutableArray alloc] initWithArray:[self.activities objectForKey:section]];
	
	if ([section isKindOfClass:[NSString class]] && [section isEqualToString:@"new"] && [sectionActivities count] == 0) {
		NSMutableArray *sectionOrderBuffer = [[NSMutableArray alloc] initWithArray:self.sectionOrder];
		
		[sectionOrderBuffer insertObject:@"new" atIndex:0];
		
		self.sectionOrder = [[NSArray alloc] initWithArray:sectionOrderBuffer];
	}
	
	[sectionActivities addObject:activity];
	
	NSArray *sortedSectionActivities = [sectionActivities sortedArrayUsingComparator:^NSComparisonResult(SLVActivity *a, SLVActivity *b) {
		NSDate *first = a.createdAt;
		NSDate *second = b.createdAt;
		return [second compare:first];
	}];
	
	NSMutableDictionary *activitiesBuffer = [[NSMutableDictionary alloc] initWithDictionary:self.activities];
	
	[activitiesBuffer setObject:sortedSectionActivities forKey:section];
	
	self.activities = [[NSDictionary alloc] initWithDictionary:activitiesBuffer];
	
	if (shouldAddSectionToSectionOrder) {
		NSMutableArray *sectionOrderBuffer = [[NSMutableArray alloc] init];
		
		for (id originalSection in self.sectionOrder) {
			if ([originalSection isKindOfClass:[NSDate class]]) {
				[sectionOrderBuffer addObject:originalSection];
			}
		}
		
		[sectionOrderBuffer addObject:section];
		
		NSMutableArray *sortedSectionOrderBuffer = [[NSMutableArray alloc] initWithArray:[sectionOrderBuffer sortedArrayUsingComparator:^NSComparisonResult(NSDate *a, NSDate *b) {
			return [b compare:a];
		}]];
		
		if ([[self.sectionOrder firstObject] isKindOfClass:[NSString class]]) {
			[sortedSectionOrderBuffer insertObject:@"new" atIndex:0];
		}
		
		self.sectionOrder = [[NSArray alloc] initWithArray:sortedSectionOrderBuffer];
	}
}

- (NSAttributedString *)formatDescriptionForActivity:(SLVActivity *)activity {
	NSString *description;
	
	switch (activity.type) {
		case kSloved: {
			description = NSLocalizedString(@"label_slove_from", nil);
			description = [description stringByReplacingOccurrencesOfString:@"[username]" withString:activity.relatedUser];
			
			break;
		}
			
		case kLevel: {
			description = NSLocalizedString(@"label_level_up", nil);
			description = [description stringByReplacingOccurrencesOfString:@"[number]" withString:[activity.value stringValue]];
			description = [description stringByReplacingOccurrencesOfString:@"[username]" withString:activity.relatedUser];
			
			break;
		}
			
		case kJoined: {
			description = NSLocalizedString(@"label_friend_joined", nil);
			description = [description stringByReplacingOccurrencesOfString:@"[username]" withString:activity.relatedUser];
			
			break;
		}
			
		case kCredit: {
			description = NSLocalizedString(@"label_received_gift", nil);
			description = [description stringByReplacingOccurrencesOfString:@"[number]" withString:[activity.value stringValue]];
			
			if ([activity.value intValue] > 1) {
				description = [description stringByReplacingOccurrencesOfString:@"[slove]" withString:@"Sloves"];
			} else {
				description = [description stringByReplacingOccurrencesOfString:@"[slove]" withString:@"Slove"];
			}
			
			break;
		}
			
		default: {
			break;
		}
	}
	
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
	
	if (activity.isNew) {
		NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
		
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE] range:NSMakeRange(0, [attributedString length])];
	} else {
		NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
		if ([SLVTools deviceIs24Hour]) {
			[hourFormatter setDateFormat:@"HH:mm"];
		} else {
			[hourFormatter setDateFormat:@"h:mm a"];
		}
		[hourFormatter setTimeZone:[NSTimeZone localTimeZone]];
		
		NSString *hourString = [[hourFormatter stringFromDate:activity.createdAt] stringByAppendingString:@" - "];
		description = [hourString stringByAppendingString:description];
		
		attributedString = [[NSMutableAttributedString alloc] initWithString:description];
		
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:DEFAULT_FONT_ITALIC size:DEFAULT_FONT_SIZE_LARGE] range:NSMakeRange(0, [attributedString length])];
		
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:DEFAULT_FONT size:DEFAULT_FONT_SIZE] range:NSMakeRange(0, [attributedString length])];
		
		NSRange timeRange = [description rangeOfString:hourString];
		[attributedString addAttribute:NSForegroundColorAttributeName
								 value:LIGHT_GRAY
								 range:timeRange];
	}
	
	NSRange relatedUserRange = [description rangeOfString:activity.relatedUser];
	if (relatedUserRange.location != NSNotFound) {
		[attributedString addAttribute:NSForegroundColorAttributeName
								 value:BLUE
								 range:relatedUserRange];
	}
	
	NSRange valueRange = [description rangeOfString:[activity.value stringValue] options:NSCaseInsensitiveSearch range:NSMakeRange(7, [description length] - 7)];
	if (valueRange.location != NSNotFound) {
		[attributedString addAttribute:NSForegroundColorAttributeName
								 value:BLUE
								 range:valueRange];
	}
	
	return attributedString;
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.sectionOrder count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	id sectionObject = [self.sectionOrder objectAtIndex:section];
	
	if ([sectionObject isKindOfClass:[NSString class]] && [sectionObject isEqualToString:@"new"]) {
		return NSLocalizedString(@"label_new_header", nil);
	} else if ([sectionObject isKindOfClass:[NSDate class]]) {
		NSDate *sectionDate = (NSDate *)sectionObject;
		
		NSDateFormatter *shortDayFormatter = [[NSDateFormatter alloc] init];
		[shortDayFormatter setDateFormat:@"EEEE"];
		[shortDayFormatter setTimeZone:[NSTimeZone localTimeZone]];
		
		return [shortDayFormatter stringFromDate:sectionDate];
	}
	
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		return 40;
	} else {
		return 30;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([[self tableView:tableView titleForHeaderInSection:section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		return 50;
	} else {
		return 30;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if ([[self tableView:tableView titleForHeaderInSection:section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		return 50;
	} else {
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *activitiesForSection = [self.activities objectForKey:[self.sectionOrder objectAtIndex:section]];
	
	return [activitiesForSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *activitiesForSection = [self.activities objectForKey:[self.sectionOrder objectAtIndex:indexPath.section]];
	
	SLVActivity *activity = [activitiesForSection objectAtIndex:indexPath.row];
	
	if ([[self tableView:tableView titleForHeaderInSection:indexPath.section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		static NSString *newActivityIdentifier = @"NewActivityCell";
		SLVNewActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:newActivityIdentifier];
		if (!cell) {
			[tableView registerNib:[UINib nibWithNibName:@"SLVNewActivityTableViewCell" bundle:nil] forCellReuseIdentifier:newActivityIdentifier];
			cell = [tableView dequeueReusableCellWithIdentifier:newActivityIdentifier];
		}
		
		[SLVViewController setStyle:cell];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		switch (activity.type) {
			case kSloved: {
				cell.logoImageView.image = [UIImage imageNamed:@"Assets/Image/pastille_slove"];
				break;
			}
				
			case kLevel: {
				cell.logoImageView.image = [UIImage imageNamed:@"Assets/Image/pastille_level"];
				break;
			}
				
			case kJoined: {
				cell.logoImageView.image = [UIImage imageNamed:@"Assets/Image/pastille_amis"];
				break;
			}
				
			case kCredit: {
				cell.logoImageView.image = [UIImage imageNamed:@"Assets/Image/pastille_kdo"];
				break;
			}
				
			default: {
				break;
			}
		}
		
		cell.descriptionLabel.attributedText = [self formatDescriptionForActivity:activity];
		
		return cell;
	} else {
		static NSString *oldActivityIdentifier = @"OldActivityCell";
		SLVOldActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:oldActivityIdentifier];
		if (!cell) {
			[tableView registerNib:[UINib nibWithNibName:@"SLVOldActivityTableViewCell" bundle:nil] forCellReuseIdentifier:oldActivityIdentifier];
			cell = [tableView dequeueReusableCellWithIdentifier:oldActivityIdentifier];
		}
		
		[SLVViewController setStyle:cell];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		cell.descriptionLabel.attributedText = [self formatDescriptionForActivity:activity];
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id section = [self.sectionOrder objectAtIndex:indexPath.section];
	SLVActivity *activity = [[self.activities objectForKey:section] objectAtIndex:indexPath.row];
	
	if (activity) {
		UIViewController *rootViewController = self.navigationController.viewControllers.firstObject;
		if ([rootViewController isKindOfClass:[SLVHomeViewController class]]) {
			SLVHomeViewController *homeViewController = (SLVHomeViewController *)rootViewController;
			
			SLVContact *contact = [homeViewController contactForUsername:activity.relatedUser];
			
			if (contact) {
				if (contact.pictureUrl) {
					SDWebImageManager *manager = [SDWebImageManager sharedManager];
					[manager downloadImageWithURL:contact.pictureUrl
										  options:0
										 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
											 SLVLog(@"Downloading '%@' profile picture: %f%", contact.username, (receivedSize / expectedSize) * 100);
										 }
										completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
											if (image) {
												ApplicationDelegate.sloverToSlove = [[NSArray alloc] initWithObjects:contact, image, nil];
												
												[self.navigationController popToRootViewControllerAnimated:YES];
											}
										}];
				} else {
					SLVLog(@"No cached picture found for %@, loading default avatar picture", contact.username);
					
					ApplicationDelegate.sloverToSlove = [[NSArray alloc] initWithObjects:contact, nil];
					
					[self.navigationController popToRootViewControllerAnimated:YES];
				}
			}
		}
	}
	
	return;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 8 * 2, [self tableView:tableView heightForHeaderInSection:section])];
	UILabel *label = [[UILabel alloc] init];
	
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.textColor = DARK_GRAY;
	
	[headerView addSubview:label];
	
	if ([[self tableView:tableView titleForHeaderInSection:section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		headerView.backgroundColor = WHITE;
		
		label.frame = CGRectMake(80, 1, 120, headerView.frame.size.height - 1 * 2);
		label.textAlignment = NSTextAlignmentCenter;
		label.backgroundColor = WHITE;
		label.font = [UIFont fontWithName:DEFAULT_FONT_TITLE size:DEFAULT_FONT_SIZE_VERY_LARGE];
		label.adjustsFontSizeToFitWidth = YES;
		
		UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, headerView.frame.size.height / 2 - 4 / 2, headerView.frame.size.width - 30 * 2, 4)];
		
		headerImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
		
		[headerView addSubview:headerImageView];
		
		[headerView bringSubviewToFront:label];
	} else {
		headerView.backgroundColor = VERY_LIGHT_GRAY;
		
		label.frame = CGRectMake(20, 1, headerView.frame.size.width - 20 * 2, headerView.frame.size.height - 1 * 2);
		label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:DEFAULT_FONT_SIZE];
	}
	
	return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if ([[self tableView:tableView titleForHeaderInSection:section] isEqualToString:NSLocalizedString(@"label_new_header", nil)]) {
		UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 8 * 2, [self tableView:tableView heightForHeaderInSection:section])];
		
		footerView.backgroundColor = WHITE;
		
		UIImageView *footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, footerView.frame.size.height / 2 - 4 / 2, footerView.frame.size.width - 30 * 2, 4)];
		
		footerImageView.image = [UIImage imageNamed:@"Assets/Image/separateur_repertoire"];
		
		[footerView addSubview:footerImageView];
		
		return footerView;
	} else {
		return nil;
	}
}

@end
