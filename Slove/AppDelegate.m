//
//  AppDelegate.m
//  Slove
//
//  Created by Guillaume Bellut on 19/07/2015.
//  Copyright (c) 2015 Tulleb's Corp. All rights reserved.
//

#import "AppDelegate.h"
#import "SLVConnectionViewController.h"
#import "SLVHomeViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "SLVSlovedPopupViewController.h"
#import <Google/Analytics.h>
#import "Reachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// [Optional] Power your app with Local Datastore. For more info, go to
	// https://parse.com/docs/ios_guide#localdatastore/iOS
	[Parse enableLocalDatastore];
 
	// Initialize Parse.
	[Parse setApplicationId:@"bNqrmF49ncJ0LYgfGIFZmReRkqKLFWtuCt2XJQFy"
				  clientKey:@"pJ5C1IkUz8hKdXd5pb3sZyDroMu6XfjhRgNiLO5q"];
 
	// [Optional] Track statistics around application opens.
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
	
	[PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

	[FBSDKLoginButton class];
	
	// Configure tracker from GoogleService-Info.plist.
	NSError *configureError;
	[[GGLContext sharedInstance] configureWithError:&configureError];
	NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
	
	// Optional: configure GAI options.
	GAI *gai = [GAI sharedInstance];
	gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
	gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
	
	[self loadUserDefaults];
	[self loadCountryCodeDatas];
	[self loadDefaultCountryCodeData];
	
	if (IS_IOS7) {
		[application registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	} else {
		UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
														UIUserNotificationTypeBadge |
														UIUserNotificationTypeSound);
		UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
																				 categories:nil];
		[application registerUserNotificationSettings:settings];
		[application registerForRemoteNotifications];
	}
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:[[SLVConnectionViewController alloc] init]];
	self.window.rootViewController = self.currentNavigationController;
	[self.currentNavigationController hideBottomNavigationBar];
	[self.window addSubview:self.currentNavigationController.view];
	[self.window makeKeyAndVisible];
	
	NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	
	//Accept push notification when app is not open
	if (remoteNotif) {
		self.queuedPushNotification = [[NSArray alloc] initWithObjects:application, remoteNotif, nil];
	}
	
	return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	self.alreadyCheckedCompatibleVersion = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	application.applicationIconBadgeNumber = 0;
	
	[self checkReachability];
	[FBSDKAppEvents activateApp];
	[self loadParseConfig];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [[FBSDKApplicationDelegate sharedInstance] application:application
														  openURL:url
												sourceApplication:sourceApplication
													   annotation:annotation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	currentInstallation.channels = @[@"global"];
	[currentInstallation saveInBackground];
	
	SLVLog(@"Device registered for push notifications");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[self application:application handleRemoteNotification:userInfo];
}


#pragma mark - Custom methods

- (void)application:(UIApplication *)application handleRemoteNotification:(NSDictionary *)userInfo {
	self.queuedPushNotification = nil;
	NSDictionary *sloverDic = [userInfo objectForKey:@"slover"];
	if (sloverDic) {
		NSError *error;
		SLVContact *slover = [[SLVContact alloc] initWithDictionary:sloverDic error:&error];
		if ([sloverDic objectForKey:@"pictureUrl"]) {
			slover.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[sloverDic objectForKey:@"pictureUrl"]]]];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
		} else {
			SLVSlovedPopupViewController *presentedViewController = [[SLVSlovedPopupViewController alloc] initWithContact:slover];
			[self.currentNavigationController presentViewController:presentedViewController animated:YES completion:nil];
			
			[ApplicationDelegate.currentNavigationController refreshSloveCounter];
		}
	} else {
		[PFPush handlePush:userInfo];
	}
	
	SLVLog(@"Received a push notification");
}

- (void)checkReachability {
	Reachability *reach = [Reachability reachabilityForInternetConnection];
	
	NetworkStatus netStatus = [reach currentReachabilityStatus];
	if (netStatus == NotReachable) {
		SLVLog(@"%@No internet connection!", SLV_ERROR);
		SLVInteractionPopupViewController *reachabilityPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_body_reachability", nil) buttonsTitle:nil andDismissButton:YES];
		[self.currentNavigationController presentViewController:reachabilityPopup animated:YES completion:nil];
	}
}

- (void)loadUserDefaults {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:KEY_FIRST_TIME_TUTORIAL]) {
		[userDefaults setObject:[NSNumber numberWithBool:YES] forKey:KEY_FIRST_TIME_TUTORIAL];
	}
}

- (void)userConnected {
	SLVLog(@"User '%@' connected on Slove", [PFUser currentUser].username);
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	currentInstallation.channels = @[@"global", [PFUser currentUser].username];
	[currentInstallation saveInBackground];
	
	if (!self.userIsConnected) {
		self.currentNavigationController = nil;
		self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:[[SLVHomeViewController alloc] init]];
		[self.currentNavigationController showBottomNavigationBar];
		self.window.rootViewController = self.currentNavigationController;
		
		if (self.queuedPushNotification) {
			[self application:[self.queuedPushNotification firstObject] handleRemoteNotification:[self.queuedPushNotification lastObject]];
		}
	}

	self.userIsConnected = YES;
}

- (void)userDisconnected {
	SLVLog(@"User disconnected from Slove");
	
	if (self.userIsConnected) {
		[self.currentNavigationController.loaderImageView showByZoomingOutWithDuration:SHORT_ANIMATION_DURATION AndCompletion:^{
			self.currentNavigationController = nil;
			
			SLVConnectionViewController *connectionViewController = [[SLVConnectionViewController alloc] init];
			
			self.currentNavigationController = [[SLVNavigationController alloc] initWithRootViewController:connectionViewController];
			[self.currentNavigationController hideBottomNavigationBar];
			self.window.rootViewController = self.currentNavigationController;
		}];
	}
	
	self.userIsConnected = NO;
}

- (void)loadCountryCodeDatas {
	NSDictionary *countryCodeDic = [NSDictionary dictionaryWithObjectsAndKeys:
									@[@"Afghanistan",@"93"],@"AF",
									@[@"Aland Islands",@"358"],@"AX",
									@[@"Albania",@"355"],@"AL",
									@[@"Algeria",@"213"],@"DZ",
									@[@"American Samoa",@"1"],@"AS",
									@[@"Andorra",@"376"],@"AD",
									@[@"Angola",@"244"],@"AO",
									@[@"Anguilla",@"1"],@"AI",
									@[@"Antarctica",@"672"],@"AQ",
									@[@"Antigua and Barbuda",@"1"],@"AG",
									@[@"Argentina",@"54"],@"AR",
									@[@"Armenia",@"374"],@"AM",
									@[@"Aruba",@"297"],@"AW",
									@[@"Australia",@"61"],@"AU",
									@[@"Austria",@"43"],@"AT",
									@[@"Azerbaijan",@"994"],@"AZ",
									@[@"Bahamas",@"1"],@"BS",
									@[@"Bahrain",@"973"],@"BH",
									@[@"Bangladesh",@"880"],@"BD",
									@[@"Barbados",@"1"],@"BB",
									@[@"Belarus",@"375"],@"BY",
									@[@"Belgium",@"32"],@"BE",
									@[@"Belize",@"501"],@"BZ",
									@[@"Benin",@"229"],@"BJ",
									@[@"Bermuda",@"1"],@"BM",
									@[@"Bhutan",@"975"],@"BT",
									@[@"Bolivia",@"591"],@"BO",
									@[@"Bosnia and Herzegovina",@"387"],@"BA",
									@[@"Botswana",@"267"],@"BW",
									@[@"Bouvet Island",@"47"],@"BV",
									@[@"BQ",@"599"],@"BQ",
									@[@"Brazil",@"55"],@"BR",
									@[@"British Indian Ocean Territory",@"246"],@"IO",
									@[@"British Virgin Islands",@"1"],@"VG",
									@[@"Brunei Darussalam",@"673"],@"BN",
									@[@"Bulgaria",@"359"],@"BG",
									@[@"Burkina Faso",@"226"],@"BF",
									@[@"Burundi",@"257"],@"BI",
									@[@"Cambodia",@"855"],@"KH",
									@[@"Cameroon",@"237"],@"CM",
									@[@"Canada",@"1"],@"CA",
									@[@"Cape Verde",@"238"],@"CV",
									@[@"Cayman Islands",@"345"],@"KY",
									@[@"Central African Republic",@"236"],@"CF",
									@[@"Chad",@"235"],@"TD",
									@[@"Chile",@"56"],@"CL",
									@[@"China",@"86"],@"CN",
									@[@"Christmas Island",@"61"],@"CX",
									@[@"Cocos (Keeling) Islands",@"61"],@"CC",
									@[@"Colombia",@"57"],@"CO",
									@[@"Comoros",@"269"],@"KM",
									@[@"Congo (Brazzaville)",@"242"],@"CG",
									@[@"Congo, Democratic Republic of the",@"243"],@"CD",
									@[@"Cook Islands",@"682"],@"CK",
									@[@"Costa Rica",@"506"],@"CR",
									@[@"Côte d'Ivoire",@"225"],@"CI",
									@[@"Croatia",@"385"],@"HR",
									@[@"Cuba",@"53"],@"CU",
									@[@"Curacao",@"599"],@"CW",
									@[@"Cyprus",@"537"],@"CY",
									@[@"Czech Republic",@"420"],@"CZ",
									@[@"Denmark",@"45"],@"DK",
									@[@"Djibouti",@"253"],@"DJ",
									@[@"Dominica",@"1"],@"DM",
									@[@"Dominican Republic",@"1"],@"DO",
									@[@"Ecuador",@"593"],@"EC",
									@[@"Egypt",@"20"],@"EG",
									@[@"El Salvador",@"503"],@"SV",
									@[@"Equatorial Guinea",@"240"],@"GQ",
									@[@"Eritrea",@"291"],@"ER",
									@[@"Estonia",@"372"],@"EE",
									@[@"Ethiopia",@"251"],@"ET",
									@[@"Falkland Islands (Malvinas)",@"500"],@"FK",
									@[@"Faroe Islands",@"298"],@"FO",
									@[@"Fiji",@"679"],@"FJ",
									@[@"Finland",@"358"],@"FI",
									@[@"France",@"33"],@"FR",
									@[@"French Guiana",@"594"],@"GF",
									@[@"French Polynesia",@"689"],@"PF",
									@[@"French Southern Territories",@"689"],@"TF",
									@[@"Gabon",@"241"],@"GA",
									@[@"Gambia",@"220"],@"GM",
									@[@"Georgia",@"995"],@"GE",
									@[@"Germany",@"49"],@"DE",
									@[@"Ghana",@"233"],@"GH",
									@[@"Gibraltar",@"350"],@"GI",
									@[@"Greece",@"30"],@"GR",
									@[@"Greenland",@"299"],@"GL",
									@[@"Grenada",@"1"],@"GD",
									@[@"Guadeloupe",@"590"],@"GP",
									@[@"Guam",@"1"],@"GU",
									@[@"Guatemala",@"502"],@"GT",
									@[@"Guernsey",@"44"],@"GG",
									@[@"Guinea",@"224"],@"GN",
									@[@"Guinea-Bissau",@"245"],@"GW",
									@[@"Guyana",@"595"],@"GY",
									@[@"Haiti",@"509"],@"HT",
									@[@"Holy See (Vatican City State)",@"379"],@"VA",
									@[@"Honduras",@"504"],@"HN",
									@[@"Hong Kong, Special Administrative Region of China",@"852"],@"HK",
									@[@"Hungary",@"36"],@"HU",
									@[@"Iceland",@"354"],@"IS",
									@[@"India",@"91"],@"IN",
									@[@"Indonesia",@"62"],@"ID",
									@[@"Iran, Islamic Republic of",@"98"],@"IR",
									@[@"Iraq",@"964"],@"IQ",
									@[@"Ireland",@"353"],@"IE",
									@[@"Isle of Man",@"44"],@"IM",
									@[@"Israel",@"972"],@"IL",
									@[@"Italy",@"39"],@"IT",
									@[@"Jamaica",@"1"],@"JM",
									@[@"Japan",@"81"],@"JP",
									@[@"Jersey",@"44"],@"JE",
									@[@"Jordan",@"962"],@"JO",
									@[@"Kazakhstan",@"77"],@"KZ",
									@[@"Kenya",@"254"],@"KE",
									@[@"Kiribati",@"686"],@"KI",
									@[@"Korea, Democratic People's Republic of",@"850"],@"KP",
									@[@"Korea, Republic of",@"82"],@"KR",
									@[@"Kuwait",@"965"],@"KW",
									@[@"Kyrgyzstan",@"996"],@"KG",
									@[@"Lao PDR",@"856"],@"LA",
									@[@"Latvia",@"371"],@"LV",
									@[@"Lebanon",@"961"],@"LB",
									@[@"Lesotho",@"266"],@"LS",
									@[@"Liberia",@"231"],@"LR",
									@[@"Libya",@"218"],@"LY",
									@[@"Liechtenstein",@"423"],@"LI",
									@[@"Lithuania",@"370"],@"LT",
									@[@"Luxembourg",@"352"],@"LU",
									@[@"Macao, Special Administrative Region of China",@"853"],@"MO",
									@[@"Macedonia, Republic of",@"389"],@"MK",
									@[@"Madagascar",@"261"],@"MG",
									@[@"Malawi",@"265"],@"MW",
									@[@"Malaysia",@"60"],@"MY",
									@[@"Maldives",@"960"],@"MV",
									@[@"Mali",@"223"],@"ML",
									@[@"Malta",@"356"],@"MT",
									@[@"Marshall Islands",@"692"],@"MH",
									@[@"Martinique",@"596"],@"MQ",
									@[@"Mauritania",@"222"],@"MR",
									@[@"Mauritius",@"230"],@"MU",
									@[@"Mayotte",@"262"],@"YT",
									@[@"Mexico",@"52"],@"MX",
									@[@"Micronesia, Federated States of",@"691"],@"FM",
									@[@"Moldova",@"373"],@"MD",
									@[@"Monaco",@"377"],@"MC",
									@[@"Mongolia",@"976"],@"MN",
									@[@"Montenegro",@"382"],@"ME",
									@[@"Montserrat",@"1"],@"MS",
									@[@"Morocco",@"212"],@"MA",
									@[@"Mozambique",@"258"],@"MZ",
									@[@"Myanmar",@"95"],@"MM",
									@[@"Namibia",@"264"],@"NA",
									@[@"Nauru",@"674"],@"NR",
									@[@"Nepal",@"977"],@"NP",
									@[@"Netherlands",@"31"],@"NL",
									@[@"Netherlands Antilles",@"599"],@"AN",
									@[@"New Caledonia",@"687"],@"NC",
									@[@"New Zealand",@"64"],@"NZ",
									@[@"Nicaragua",@"505"],@"NI",
									@[@"Niger",@"227"],@"NE",
									@[@"Nigeria",@"234"],@"NG",
									@[@"Niue",@"683"],@"NU",
									@[@"Norfolk Island",@"672"],@"NF",
									@[@"Northern Mariana Islands",@"1"],@"MP",
									@[@"Norway",@"47"],@"NO",
									@[@"Oman",@"968"],@"OM",
									@[@"Pakistan",@"92"],@"PK",
									@[@"Palau",@"680"],@"PW",
									@[@"Palestinian Territory, Occupied",@"970"],@"PS",
									@[@"Panama",@"507"],@"PA",
									@[@"Papua New Guinea",@"675"],@"PG",
									@[@"Paraguay",@"595"],@"PY",
									@[@"Peru",@"51"],@"PE",
									@[@"Philippines",@"63"],@"PH",
									@[@"Pitcairn",@"872"],@"PN",
									@[@"Poland",@"48"],@"PL",
									@[@"Portugal",@"351"],@"PT",
									@[@"Puerto Rico",@"1"],@"PR",
									@[@"Qatar",@"974"],@"QA",
									@[@"Réunion",@"262"],@"RE",
									@[@"Romania",@"40"],@"RO",
									@[@"Russian Federation",@"7"],@"RU",
									@[@"Rwanda",@"250"],@"RW",
									@[@"Saint Helena",@"290"],@"SH",
									@[@"Saint Kitts and Nevis",@"1"],@"KN",
									@[@"Saint Lucia",@"1"],@"LC",
									@[@"Saint Pierre and Miquelon",@"508"],@"PM",
									@[@"Saint Vincent and Grenadines",@"1"],@"VC",
									@[@"Saint-Barthélemy",@"590"],@"BL",
									@[@"Saint-Martin (French part)",@"590"],@"MF",
									@[@"Samoa",@"685"],@"WS",
									@[@"San Marino",@"378"],@"SM",
									@[@"Sao Tome and Principe",@"239"],@"ST",
									@[@"Saudi Arabia",@"966"],@"SA",
									@[@"Senegal",@"221"],@"SN",
									@[@"Serbia",@"381"],@"RS",
									@[@"Seychelles",@"248"],@"SC",
									@[@"Sierra Leone",@"232"],@"SL",
									@[@"Singapore",@"65"],@"SG",
									@[@"Sint Maarten",@"1"],@"SX",
									@[@"Slovakia",@"421"],@"SK",
									@[@"Slovenia",@"386"],@"SI",
									@[@"Solomon Islands",@"677"],@"SB",
									@[@"Somalia",@"252"],@"SO",
									@[@"South Africa",@"27"],@"ZA",
									@[@"South Georgia and the South Sandwich Islands",@"500"],@"GS",
									@[@"South Sudan",@"211"],@"SS​",
									@[@"Spain",@"34"],@"ES",
									@[@"Sri Lanka",@"94"],@"LK",
									@[@"Sudan",@"249"],@"SD",
									@[@"Suriname",@"597"],@"SR",
									@[@"Svalbard and Jan Mayen Islands",@"47"],@"SJ",
									@[@"Swaziland",@"268"],@"SZ",
									@[@"Sweden",@"46"],@"SE",
									@[@"Switzerland",@"41"],@"CH",
									@[@"Syrian Arab Republic (Syria)",@"963"],@"SY",
									@[@"Taiwan, Republic of China",@"886"],@"TW",
									@[@"Tajikistan",@"992"],@"TJ",
									@[@"Tanzania, United Republic of",@"255"],@"TZ",
									@[@"Thailand",@"66"],@"TH",
									@[@"Timor-Leste",@"670"],@"TL",
									@[@"Togo",@"228"],@"TG",
									@[@"Tokelau",@"690"],@"TK",
									@[@"Tonga",@"676"],@"TO",
									@[@"Trinidad and Tobago",@"1"],@"TT",
									@[@"Tunisia",@"216"],@"TN",
									@[@"Turkey",@"90"],@"TR",
									@[@"Turkmenistan",@"993"],@"TM",
									@[@"Turks and Caicos Islands",@"1"],@"TC",
									@[@"Tuvalu",@"688"],@"TV",
									@[@"Uganda",@"256"],@"UG",
									@[@"Ukraine",@"380"],@"UA",
									@[@"United Arab Emirates",@"971"],@"AE",
									@[@"United Kingdom",@"44"],@"GB",
									@[@"United States of America",@"1"],@"US",
									@[@"Uruguay",@"598"],@"UY",
									@[@"Uzbekistan",@"998"],@"UZ",
									@[@"Vanuatu",@"678"],@"VU",
									@[@"Venezuela (Bolivarian Republic of)",@"58"],@"VE",
									@[@"Viet Nam",@"84"],@"VN",
									@[@"Virgin Islands, US",@"1"],@"VI",
									@[@"Wallis and Futuna Islands",@"681"],@"WF",
									@[@"Western Sahara",@"212"],@"EH",
									@[@"Yemen",@"967"],@"YE",
									@[@"Zambia",@"260"],@"ZM",
									@[@"Zimbabwe",@"263"],@"ZW", nil];
	
	NSArray *countryKeys = [countryCodeDic allKeys];
	NSMutableArray *countryCodeBuffer = [[NSMutableArray alloc] init];
	
	for (NSString *key in countryKeys) {
		NSArray *values = [countryCodeDic objectForKey:key];
		
		SLVCountryCodeData *countryCodeData = [[SLVCountryCodeData alloc] init];
		countryCodeData.ISOCode = key;
		countryCodeData.country = [values firstObject];
		countryCodeData.countryCode = [values lastObject];
		
		[countryCodeBuffer addObject:countryCodeData];
	}
	
	self.countryCodeDatas = [countryCodeBuffer sortedArrayUsingComparator:^(SLVCountryCodeData *a, SLVCountryCodeData *b) {
		return [a.country caseInsensitiveCompare:b.country];
	}];
}

- (void)loadDefaultCountryCodeData {
	NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];

	if (countryCode) {
		for (SLVCountryCodeData *countryCodeData in self.countryCodeDatas) {
			if ([countryCode isEqualToString:countryCodeData.ISOCode]) {
				self.userCountryCodeData = countryCodeData;
				
				SLVLog(@"Default country code data found and set to '%@'", self.userCountryCodeData.country);
			}
		}
		
		if (!self.userCountryCodeData) {
			SLVLog(@"%@No default country code data found for the country code '%@'", SLV_WARNING, countryCode);
		}
	} else {
		SLVLog(@"%@No country value found on this device", SLV_WARNING);
	}
}

- (void)loadParseConfig {
	self.parseConfig = [[NSMutableDictionary alloc] init];
	SLVLog(@"Getting the latest config...");
	
	[PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
		if (!error) {
			SLVLog(@"Config was fetched from the server");
		} else {
			SLVLog(@"%@Failed to fetch, using cached Config", SLV_WARNING);
			config = [PFConfig currentConfig];
		}
		
		if (error) {
			SLVLog(@"%@%@", SLV_ERROR, error.description);
			[ParseErrorHandlingController handleParseError:error];
		}
		
		NSString *firstSloveUsername = config[PARSE_FIRST_SLOVE_USERNAME];
		if (!firstSloveUsername) {
			SLVLog(@"%@Falling back to default first slove username", SLV_ERROR);
			firstSloveUsername = NSLocalizedString(@"label_slove_team", nil);
		}
		
		[self.parseConfig setObject:firstSloveUsername forKey:PARSE_FIRST_SLOVE_USERNAME];
		
		NSString *compatibleVersion = config[PARSE_COMPATIBLE_VERSION];
		if (!compatibleVersion) {
			SLVLog(@"%@Couldn't find compatible version", SLV_ERROR);
		} else {
			[self.parseConfig setObject:compatibleVersion forKey:PARSE_COMPATIBLE_VERSION];
		}
		
		NSString *downloadAppUrl = config[PARSE_DOWNLOAD_APP_URL];
		if (!downloadAppUrl) {
			SLVLog(@"%@Couldn't find download app url", SLV_ERROR);
		} else {
			[self.parseConfig setObject:downloadAppUrl forKey:PARSE_DOWNLOAD_APP_URL];
		}
		
		__block UIImage *firstSlovePicture;
		PFFile *firstSlovePictureFile = config[PARSE_FIRST_SLOVE_PICTURE];
		if (!firstSlovePictureFile) {
			SLVLog(@"%@Falling back to default first slove picture", SLV_ERROR);
			firstSlovePicture = [UIImage imageNamed:@"Assets/Image/photo_team_slove"];
			[self.parseConfig setObject:firstSlovePicture forKey:PARSE_FIRST_SLOVE_PICTURE];
		} else if (firstSlovePictureFile.isDataAvailable) {
			firstSlovePicture = [UIImage imageWithData:[firstSlovePictureFile getData]];
			[self.parseConfig setObject:firstSlovePicture forKey:PARSE_FIRST_SLOVE_PICTURE];
		} else {
			[firstSlovePictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
				if (!error) {
					firstSlovePicture = [UIImage imageWithData:data];
					[self.parseConfig setObject:firstSlovePicture forKey:PARSE_FIRST_SLOVE_PICTURE];
				} else {
					SLVLog(@"%@Error when downloading %@, falling back to default first slove picture", SLV_ERROR, PARSE_FIRST_SLOVE_PICTURE);
					firstSlovePicture = [UIImage imageNamed:@"Assets/Image/photo_team_slove"];
					[self.parseConfig setObject:firstSlovePicture forKey:PARSE_FIRST_SLOVE_PICTURE];
				}
			}];
		}
		
		if (!self.alreadyCheckedCompatibleVersion) {
			[self checkCompatibleVersion];
		}
	}];
}

- (void)checkCompatibleVersion {
	NSString *compatibleVersion = [self.parseConfig objectForKey:PARSE_COMPATIBLE_VERSION];
	if (compatibleVersion) {
		NSPredicate *compatibleVersionRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", compatibleVersion];
		NSString *fullVersion = [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
		
		if (![compatibleVersionRegex evaluateWithObject:fullVersion]) {
			SLVLog(@"%@Incompatible versions : expected version is %@ whereas current version is %@", SLV_WARNING, compatibleVersion, fullVersion);
			
			self.compatibleVersionPopup = [[SLVInteractionPopupViewController alloc] initWithTitle:NSLocalizedString(@"popup_title_error", nil) body:NSLocalizedString(@"popup_incompatible_version_error", nil) buttonsTitle:[NSArray arrayWithObjects:NSLocalizedString(@"button_ok", nil), nil] andDismissButton:NO];
			
			self.compatibleVersionPopup.delegate = self;
			
			[self.currentNavigationController presentViewController:self.compatibleVersionPopup animated:YES completion:nil];
		}
	}
	
	self.alreadyCheckedCompatibleVersion = YES;
}


#pragma mark - SLVInteractionPopupDelegate

- (void)soloButtonPressed:(SLVInteractionPopupViewController *)popup {
	if (popup == self.compatibleVersionPopup) {
		NSString *downloadUrlString = [self.parseConfig objectForKey:PARSE_DOWNLOAD_APP_URL];
		if (downloadUrlString) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrlString]];
		}
	}
}

@end
