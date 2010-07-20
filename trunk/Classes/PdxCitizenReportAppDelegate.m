//
//  PdxCitizenReportAppDelegate.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright City of Portland 2009. All rights reserved.
//

#import "PdxCitizenReportAppDelegate.h"
#import "LocationController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "CRMReportDefinition.h"
#import "DataRepository.h"
#import "AppSettings.h"
#import "Report.h"
#import "DDXML.h"

@implementation PdxCitizenReportAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize timeBackgrounded;

- (void)dealloc {
	[timeBackgrounded release];
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	globalData.tabBarController = self.tabBarController;
	
	// get path to this application's documents folder
	[globalData setDocumentsFolder:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
	[globalData setUnsentReportFilePath:[[[DataRepository sharedInstance] documentsFolder] stringByAppendingPathComponent:@"unsent.report.dat"]];
	[globalData setAppSettingsFilePath:[[[DataRepository sharedInstance] documentsFolder] stringByAppendingPathComponent:@"settings.dat"]];
	
	// pull in misc application state info
	[self loadAppSettings];
	
	// increment the usage warning counter
	AppSettings *settings = globalData.appSettings;
	settings.usageWarningCounter = settings.usageWarningCounter + 1;
	if (settings.usageWarningCounter > settings.usageWarningInterval) {
		settings.usageWarningCounter = 1;
	}
		
	// check for initial internet connectivity
	if ([globalData internetIsReachableRightNow] == YES) {
		// load server settings
		[self populateServerSettings:YES];
	}
	
	// pull in an unsaved report (if available)
	[self loadUnsentReport];
			
	// get the location manager up and running to receive GPS locations
	LocationController *locationController = [LocationController sharedInstance];
	[locationController start];
		
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// cache time so we can tell how long app has been suspended
	self.timeBackgrounded = [NSDate date];
	// serialize app state
	[self saveAppSettings];
	[self saveUnsentReport];
	// stop location services
	LocationController *locationController = [LocationController sharedInstance];
	[locationController stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	
	// re-start location services
	LocationController *locationController = [LocationController sharedInstance];
	[locationController start];
	
	// if any of the server side calls did not complete, use this opportunity to try them all again
	bool repopulateServerData = NO;
	if (globalData.blackListWasLoaded == NO || globalData.reportTypesWereLoaded == NO || globalData.serverSettingsWereLoaded == NO || globalData.deviceSettingsWereLoaded == NO) {
		repopulateServerData = YES;
	}
	
	if (self.timeBackgrounded != nil)
	{
		NSTimeInterval interval = [self.timeBackgrounded timeIntervalSinceNow];
		if (fabs(interval) >= 1800)
		{
			// App has been suspended for a while, refresh all server side data
			repopulateServerData = YES;
			// clear out any location that was cached as part of an unsent report
			globalData.proposedLocation = nil;
			if (globalData.unsentReport != nil)
			{
				globalData.unsentReport.latitude = 0;
				globalData.unsentReport.longitude = 0;
				globalData.unsentReport.horizontalAccuracyInMeters = 0;
			}
		}
	}

	if (repopulateServerData == YES) {
		[self populateServerSettings:YES];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_AppComingToForeground object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveAppSettings];
	[self saveUnsentReport];
}

#pragma mark blacklist request and parsing

- (void)populateDeviceBlackListInfo:(bool)resetRetryCounter {
	DataRepository.sharedInstance.blackListWasLoaded = NO;
	if (resetRetryCounter == YES) {
		populateDeviceBlackListInfoRetryCount = 0;	
	}
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getBlacklistStatusUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];	
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"check_blacklist" forKey:@"request_type"]];
		[request setTimeOutSeconds:60];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateDeviceBlackListInfo {
	populateDeviceBlackListInfoRetryCount++;
	if (populateDeviceBlackListInfoRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateDeviceBlackListInfoRetryCount);
		[self populateDeviceBlackListInfo:NO];			
	}
}

- (void)parseDeviceBlackListXml:(NSString *)xmlData andHttpResponseCode:(int)code {

	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		DDXMLNode *rootNode = [xmlDocument rootElement];
		int i, count = [rootNode childCount];
		for (i = 0; i < count; i++) {
			DDXMLNode *childNode = [rootNode childAtIndex:i];
			if ([[[childNode name] lowercaseString] isEqualToString:@"status"]) {
				if ([[[childNode stringValue] lowercaseString] isEqualToString:@"y"]) {
					[[DataRepository sharedInstance] setDeviceIsBlackListed:YES];
				}
				else {
					[[DataRepository sharedInstance] setDeviceIsBlackListed:NO];
				}
			}
			if ([[[childNode name] lowercaseString] isEqualToString:@"reason"]) {
				[[DataRepository sharedInstance] setBlackListReason:[childNode stringValue]];
			}
		}
		[xmlDocument release];
		DataRepository.sharedInstance.blackListWasLoaded = YES;
	}
	return;
}

#pragma mark CRM (report) instance request and parsing

- (void)populateReportTypeArray:(bool)resetRetryCounter {
	DataRepository.sharedInstance.reportTypesWereLoaded = NO;
	if (resetRetryCounter == YES) {
		populateTrackItInstanceArrayRetryCount = 0;	
	}
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getReportDefinitionsUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"get_instances" forKey:@"request_type"]];
		[request setTimeOutSeconds:60];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateReportTypeArray {
	populateTrackItInstanceArrayRetryCount++;
	if (populateTrackItInstanceArrayRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateTrackItInstanceArrayRetryCount);
		[self populateReportTypeArray:NO];			
	}
}

- (void)parseReportTypeXml:(NSString *)xmlData andHttpResponseCode:(int)code {
		
	NSMutableArray *availableReportsArray = [[DataRepository sharedInstance] crmReportDefinitionArray];
	[availableReportsArray removeAllObjects];
	
	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		
		// XML attributes from CRM which define the report types configured for smartphone access
		NSString *crmInstanceIdAttribute = @"instance_id";
		NSString *reportIdAttribute = @"category_id";
		NSString *reportNameAttribute = @"iphone_input_alias";
		NSString *reportMessageToUserAttribute = @"iphone_message";
		NSString *imageFieldNameAttribute = @"iphone_binary_input_id";
		NSString *commentsFieldNameAttribute = @"iphone_text_input_id";
		NSString *addressFieldNameAttribute = @"iphone_address_input_id";
		NSString *imageRequiredAttribute = @"iphone_binary_input_required";
		NSString *addressRequiredAttribute = @"iphone_address_input_required";
		NSString *commentsRequiredAttribute = @"iphone_text_input_required";
				
		DDXMLNode *rootNode = [xmlDocument rootElement];
		NSArray *instanceNodeArray = [rootNode children];
		int i, count = [instanceNodeArray count];
		for (i = 0; i < count; i++) {
			DDXMLElement *reportElement = [instanceNodeArray objectAtIndex:i];
			
			CRMReportDefinition *report = [[CRMReportDefinition alloc]init];
			
			DDXMLNode *instanceAttribute = [reportElement attributeForName:crmInstanceIdAttribute];
			if (instanceAttribute != nil) {
				[report setNumber:[[instanceAttribute stringValue] integerValue]];
			}
			instanceAttribute = [reportElement attributeForName:reportIdAttribute];
			if (instanceAttribute != nil) {
				[report setCategory:[[instanceAttribute stringValue] integerValue]];
			}
			instanceAttribute = [reportElement attributeForName:reportNameAttribute];
			if (instanceAttribute != nil) {
				[report setInstanceName:[instanceAttribute stringValue]];
			}			
			instanceAttribute = [reportElement attributeForName:imageFieldNameAttribute];
			if (instanceAttribute != nil) {
				[report setImageFieldName:[instanceAttribute stringValue]];
			}	
			instanceAttribute = [reportElement attributeForName:commentsFieldNameAttribute];
			if (instanceAttribute != nil) {
				[report setCommentsFieldName:[instanceAttribute stringValue]];
			}
			instanceAttribute = [reportElement attributeForName:reportMessageToUserAttribute];
			if (instanceAttribute != nil) {
				[report setInstanceMessage:[instanceAttribute stringValue]];
			}
			instanceAttribute = [reportElement attributeForName:imageRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[report setImageRequired:YES];
				}
				else {
					[report setImageRequired:NO];
				}
			}
			instanceAttribute = [reportElement attributeForName:addressRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[report setAddressRequired:YES];
				}
				else {
					[report setAddressRequired:NO];
				}
			}
			instanceAttribute = [reportElement attributeForName:commentsRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[report setCommentsRequired:YES];
				}
				else {
					[report setCommentsRequired:NO];
				}
			}
			NSString *thisAddressFieldNamePrefix = nil;
			instanceAttribute = [reportElement attributeForName:addressFieldNameAttribute];
			if (instanceAttribute != nil) {
				thisAddressFieldNamePrefix = [instanceAttribute stringValue];
				[report setAddressFieldName:thisAddressFieldNamePrefix];
				// the x/y coordinate field names are constructed by appending to the discovered address field name
				[report setXCoordFieldName:[thisAddressFieldNamePrefix stringByAppendingString:@"_long"]];
				[report setYCoordFieldName:[thisAddressFieldNamePrefix stringByAppendingString:@"_lat"]];
			}
			[availableReportsArray addObject:report];
			[report release];
		}
		[xmlDocument release];
		DataRepository.sharedInstance.reportTypesWereLoaded = YES;
	}
	return;
}

#pragma mark Server settings request and parsing 


- (void)populateServerSettings:(bool)resetRetryCounter {
	DataRepository.sharedInstance.serverSettingsWereLoaded = NO;
	if (resetRetryCounter == YES) {
		populateIPhoneServerSettingsRetryCount = 0;
	}
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getServerSettingsUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:globalData.verifyValue forKey:@"verify"];
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"server_settings" forKey:@"request_type"]];
		[request setTimeOutSeconds:60];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateServerSettings {
	populateIPhoneServerSettingsRetryCount++;
	if (populateIPhoneServerSettingsRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateIPhoneServerSettingsRetryCount);
		[self populateServerSettings:NO];			
	}
}

- (void)parseServerSettings:(NSString *)xmlData andHttpResponseCode:(int)code {

	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		DDXMLNode *rootNode = [xmlDocument rootElement];
		if ([rootNode childCount] == 1) {
			DDXMLNode *childNode = [rootNode childAtIndex:0];		
			if ([[[childNode name] lowercaseString] isEqualToString:@"server_name"]) {
				NSURL *testURL = [NSURL URLWithString:[childNode stringValue]];
				if (testURL != nil) {
					DataRepository.sharedInstance.urlPrefix = [childNode stringValue];
				}
			}				
		}
		[xmlDocument release];
		DataRepository.sharedInstance.serverSettingsWereLoaded = YES;
	}
	return;
}

#pragma mark device settings request and parsing

- (void)populateDeviceSettings:(bool)resetRetryCounter {
	DataRepository.sharedInstance.deviceSettingsWereLoaded = NO;
	if (resetRetryCounter == YES) {
		populateIPhoneAppSettingsRetryCount = 0;
	}
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getAppSettingsUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"app_settings" forKey:@"request_type"]];
		[request setTimeOutSeconds:60];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateDeviceSettings {
	populateIPhoneAppSettingsRetryCount++;
	if (populateIPhoneAppSettingsRetryCount <= 3) {
		[self populateDeviceSettings:NO];			
	}
}

- (void)parseDeviceSettings:(NSString *)xmlData andHttpResponseCode:(int)code {
	
	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		DDXMLNode *rootNode = [xmlDocument rootElement];
		if (rootNode.childCount == 1) {
			DDXMLNode *settingsNode = [rootNode childAtIndex:0];
			NSArray *settingsNodeArray = [settingsNode children];
			int i, count = [settingsNodeArray count];
			for (i = 0; i < count; i++) {
				DDXMLNode *settingNode = [settingsNodeArray objectAtIndex:i];
				if ([[[settingNode name] lowercaseString] isEqualToString:@"gps_accuracy_threshold"]) {
					double newAccuracyValue = [[settingNode stringValue] doubleValue];
					if (newAccuracyValue > 0) {
						DataRepository.sharedInstance.appSettings.requiredGPSAccuracyInMeters = newAccuracyValue;
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"photo_max_pixels"]) {
					NSInteger newPhotoResolutionValue = [[settingNode stringValue] integerValue];
					if (newPhotoResolutionValue > 0) {
						DataRepository.sharedInstance.appSettings.photoLargestSideInPixels = newPhotoResolutionValue;
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"photo_compression"]) {
					float newCompressionValue = [[settingNode stringValue] floatValue];
					if (newCompressionValue > 0) {
						DataRepository.sharedInstance.appSettings.jpegCompressionFactor = newCompressionValue;
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"gps_sample_interval"]) {
					NSInteger newGpsSampleItervalValue = [[settingNode stringValue] integerValue];
					if (newGpsSampleItervalValue > 0) {
						DataRepository.sharedInstance.appSettings.gpsSampleIntervalInSeconds = newGpsSampleItervalValue;
					}
					continue;
				}				
				if ([[[settingNode name] lowercaseString] isEqualToString:@"gps_sample_count"]) {
					NSInteger newGpsSampleCountValue = [[settingNode stringValue] integerValue];
					if (newGpsSampleCountValue > 0) {
						DataRepository.sharedInstance.appSettings.gpsSampleCount = newGpsSampleCountValue;
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"help_page"]) {
					NSString *newHelpPageValue = [settingNode stringValue];
					if (newHelpPageValue.length > 0) {
						DataRepository.sharedInstance.appSettings.helpPageAddress = newHelpPageValue;
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"disclaimer_frequency"]) {
					NSString *newWarningIntervalValue = [settingNode stringValue];
					if (newWarningIntervalValue.length > 0) {
						DataRepository.sharedInstance.appSettings.usageWarningInterval = [newWarningIntervalValue integerValue];
					}
					continue;
				}
				if ([[[settingNode name] lowercaseString] isEqualToString:@"disclaimer_text"]) {
					NSString *newWarningText = [settingNode stringValue];
					if (newWarningText.length > 0) {
						DataRepository.sharedInstance.appSettings.usageWarningText = newWarningText;
					}
					continue;
				}
			}
		}
		[xmlDocument release];
		DataRepository.sharedInstance.deviceSettingsWereLoaded = YES;
	}
}

#pragma mark object serialization

- (void)saveAppSettings {
	
	AppSettings *appSettings = [[DataRepository sharedInstance] appSettings];
	if (appSettings != nil) {	
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:appSettings.userName forKey:@"FullName"];
		[prefs setObject:appSettings.userEmailAddress forKey:@"Email"];
		[prefs setObject:appSettings.userTelephoneNumber forKey:@"PhoneNumber"];
		[prefs setObject:appSettings.helpPageAddress forKey:@"HelpPageURL"];
		[prefs setObject:appSettings.usageWarningText forKey:@"WarningText"];
		[prefs setInteger:appSettings.usageWarningInterval forKey:@"WarningInterval"];
		[prefs setInteger:appSettings.usageWarningCounter forKey:@"WarningCounter"];
	}
}
- (void)loadAppSettings {
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	AppSettings *appSettings = [[DataRepository sharedInstance] appSettings];
	appSettings.userName = [prefs stringForKey:@"FullName"];
	appSettings.userEmailAddress = [prefs stringForKey:@"Email"];
	appSettings.userTelephoneNumber = [prefs stringForKey:@"PhoneNumber"];
	appSettings.helpPageAddress = [prefs stringForKey:@"HelpPageURL"];
	appSettings.usageWarningText = [prefs stringForKey:@"WarningText"];
	appSettings.usageWarningInterval = [prefs integerForKey:@"WarningInterval"];
	appSettings.usageWarningCounter = [prefs integerForKey:@"WarningCounter"];

}


- (void)saveUnsentReport {
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[DataRepository sharedInstance] unsentReportFilePath]] == YES) {
		[[NSFileManager defaultManager] removeItemAtPath:[[DataRepository sharedInstance] unsentReportFilePath] error:nil];
	}
	if ([[DataRepository sharedInstance] unsentReport] != nil) {	
		NSMutableData *rawData = [NSMutableData data];
		NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:rawData];
		[encoder encodeObject:[[DataRepository sharedInstance] unsentReport] forKey:@"UnsentReport"];
		[encoder finishEncoding];
		[rawData writeToFile:[[DataRepository sharedInstance] unsentReportFilePath] atomically:YES];
		[encoder release];
	}
}
- (void)loadUnsentReport {

	if ([[NSFileManager defaultManager] fileExistsAtPath:[[DataRepository sharedInstance] unsentReportFilePath]] == YES) {
		NSMutableData *rawData = [NSData dataWithContentsOfFile:[[DataRepository sharedInstance] unsentReportFilePath]];
		NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:rawData];
		[[DataRepository sharedInstance] setUnsentReport:[decoder decodeObjectForKey:@"UnsentReport"]];
		[decoder finishDecoding];
		[decoder release];
	} 
}


#pragma mark HTTP request success/failure callbacks and supporting methods

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	if (request.responseStatusCode != 200)
	{
		[self requestFailed:request];
		return;
	} 
	
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	NSString *responseString = [request responseString];
	
	if ([requestType isEqualToString:@"server_settings"]) {
		[self parseServerSettings:responseString andHttpResponseCode:request.responseStatusCode];
		// now that the server request finished, we can start the next requests since
		// the URL used by these requests could be modified by the results of the initial query
		// get the configured report types from TrackIT
		[self populateReportTypeArray:YES];
		// get server side app settings
		[self populateDeviceSettings:YES];	
		// load device blacklist info
		[self populateDeviceBlackListInfo:YES];
		return;
	}
	if ([requestType isEqualToString:@"check_blacklist"]) {
		[self parseDeviceBlackListXml:responseString andHttpResponseCode:request.responseStatusCode];
		return;
	}	
	if ([requestType isEqualToString:@"get_instances"]) {
		//NSLog(@"TrackIt Instance XML: %@",responseString);
		[self parseReportTypeXml:responseString andHttpResponseCode:request.responseStatusCode];
		return;
	}
	if ([requestType isEqualToString:@"app_settings"]) {
		[self parseDeviceSettings:responseString andHttpResponseCode:request.responseStatusCode];
		return;
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
		
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"server_settings"]) {	
		[self retryPopulateServerSettings];
	}
	if ([requestType isEqualToString:@"check_blacklist"]) {
		[self retryPopulateDeviceBlackListInfo];
	}	
	if ([requestType isEqualToString:@"get_instances"]) {
		[self retryPopulateReportTypeArray];
	}
	if ([requestType isEqualToString:@"app_settings"]) {
		[self retryPopulateDeviceSettings];
	}
}

@end

