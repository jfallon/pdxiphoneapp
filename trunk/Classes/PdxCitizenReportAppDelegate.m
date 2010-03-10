//
//  PdxCitizenReportAppDelegate.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "PdxCitizenReportAppDelegate.h"
#import "LocationController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TrackItInstance.h"
#import "DataRepository.h"
#import "AppSettings.h"
#import "DDXML.h"

@implementation PdxCitizenReportAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)dealloc {
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
		populateIPhoneServerSettingsRetryCount = 0;
		[self populateServerSettings];
	}
	
	// pull in an unsaved report (if available)
	[self loadUnsentReport];
			
	// get the location manager up and running to receive GPS locations
	LocationController *locationController = [LocationController sharedInstance];
	[locationController start];
		
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveAppSettings];
	// if we have a report that has not been sent, save it before exiting
	[self saveUnsentReport];
}

#pragma mark blacklist request and parsing

- (void)populateDeviceBlackListInfo {
	
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getBlacklistStatusUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];	
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"check_blacklist" forKey:@"request_type"]];
		[request setTimeOutSeconds:30];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateDeviceBlackListInfo {
	populateDeviceBlackListInfoRetryCount++;
	if (populateDeviceBlackListInfoRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateDeviceBlackListInfoRetryCount);
		[self populateDeviceBlackListInfo];			
	}
	else {
		//NSLog(@"Giving up after %ld attempts",(long)populateDeviceBlackListInfoRetryCount);
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
	}
	return;
}

#pragma mark trackIT (report) instance request and parsing

- (void)populateTrackItInstanceArray {
	
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getTrackItInstancesUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"get_instances" forKey:@"request_type"]];
		[request setTimeOutSeconds:30];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateTrackItInstanceArray {
	populateTrackItInstanceArrayRetryCount++;
	if (populateTrackItInstanceArrayRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateTrackItInstanceArrayRetryCount);
		[self populateTrackItInstanceArray];			
	}
	else {
		//NSLog(@"Giving up after %ld attempts",(long)populateTrackItInstanceArrayRetryCount);
	}
}

- (void)parseTrackItInstanceXml:(NSString *)xmlData andHttpResponseCode:(int)code {
		
	NSMutableArray *trackItInstanceArray = [[DataRepository sharedInstance] trackItInstanceArray];
	
	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		
		NSString *instanceIdAttribute = @"instance_id";
		NSString *categoryIdAttribute = @"category_id";
		NSString *categoryNameAttribute = @"iphone_input_alias";
		NSString *iphoneImageFieldNameAttribute = @"iphone_binary_input_id";
		NSString *iphoneCommentsFieldNameAttribute = @"iphone_text_input_id";
		NSString *iphoneAddressFieldNameAttribute = @"iphone_address_input_id";
		NSString *iphoneMessageAttribute = @"iphone_message";
		NSString *imageRequiredAttribute = @"iphone_binary_input_required";
		NSString *addressRequiredAttribute = @"iphone_address_input_required";
		NSString *commentsRequiredAttribute = @"iphone_text_input_required";
				
		DDXMLNode *rootNode = [xmlDocument rootElement];
		NSArray *instanceNodeArray = [rootNode children];
		int i, count = [instanceNodeArray count];
		for (i = 0; i < count; i++) {
			DDXMLElement *instanceElement = [instanceNodeArray objectAtIndex:i];
			
			TrackItInstance *instance = [[TrackItInstance alloc]init];
			
			DDXMLNode *instanceAttribute = [instanceElement attributeForName:instanceIdAttribute];
			if (instanceAttribute != nil) {
				[instance setNumber:[[instanceAttribute stringValue] integerValue]];
			}
			instanceAttribute = [instanceElement attributeForName:categoryIdAttribute];
			if (instanceAttribute != nil) {
				[instance setCategory:[[instanceAttribute stringValue] integerValue]];
			}
			instanceAttribute = [instanceElement attributeForName:categoryNameAttribute];
			if (instanceAttribute != nil) {
				[instance setInstanceName:[instanceAttribute stringValue]];
			}			
			instanceAttribute = [instanceElement attributeForName:iphoneImageFieldNameAttribute];
			if (instanceAttribute != nil) {
				[instance setImageInputName:[instanceAttribute stringValue]];
			}	
			instanceAttribute = [instanceElement attributeForName:iphoneCommentsFieldNameAttribute];
			if (instanceAttribute != nil) {
				[instance setCommentsInputName:[instanceAttribute stringValue]];
			}
			instanceAttribute = [instanceElement attributeForName:iphoneMessageAttribute];
			if (instanceAttribute != nil) {
				[instance setInstanceMessage:[instanceAttribute stringValue]];
			}
			instanceAttribute = [instanceElement attributeForName:imageRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[instance setImageRequired:YES];
				}
				else {
					[instance setImageRequired:NO];
				}
			}
			instanceAttribute = [instanceElement attributeForName:addressRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[instance setAddressRequired:YES];
				}
				else {
					[instance setAddressRequired:NO];
				}
			}
			instanceAttribute = [instanceElement attributeForName:commentsRequiredAttribute];
			if (instanceAttribute != nil) {
				if ([[instanceAttribute stringValue] isEqualToString:@"1"]) {
					[instance setCommentsRequired:YES];
				}
				else {
					[instance setCommentsRequired:NO];
				}
			}
			NSString *thisiPhoneAddressFieldNamePrefix = nil;
			instanceAttribute = [instanceElement attributeForName:iphoneAddressFieldNameAttribute];
			if (instanceAttribute != nil) {
				thisiPhoneAddressFieldNamePrefix = [instanceAttribute stringValue];
				[instance setAddressStringInputName:thisiPhoneAddressFieldNamePrefix];
				[instance setAddressXInputName:[thisiPhoneAddressFieldNamePrefix stringByAppendingString:@"_long"]];
				[instance setAddressYInputName:[thisiPhoneAddressFieldNamePrefix stringByAppendingString:@"_lat"]];
			}
			[trackItInstanceArray addObject:instance];
			[instance release];
		}
		[xmlDocument release];
	}
	return;
}

#pragma mark Server settings request and parsing 


- (void)populateServerSettings {
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getServerSettingsUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:globalData.verifyValue forKey:@"verify"];
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"server_settings" forKey:@"request_type"]];
		[request setTimeOutSeconds:30];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateServerSettings {
	populateIPhoneServerSettingsRetryCount++;
	if (populateIPhoneServerSettingsRetryCount <= 3) {
		//NSLog(@"Retry Attempt #%ld",(long)populateIPhoneServerSettingsRetryCount);
		[self populateServerSettings];			
	}
	else {
		//NSLog(@"Giving up after %ld attempts",(long)populateIPhoneServerSettingsRetryCount);
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
	}
	return;
}

#pragma mark device settings request and parsing

- (void)populateDeviceSettings {
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getAppSettingsUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"app_settings" forKey:@"request_type"]];
		[request setTimeOutSeconds:30];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

- (void)retryPopulateDeviceSettings {
	populateIPhoneAppSettingsRetryCount++;
	if (populateIPhoneAppSettingsRetryCount <= 3) {
		[self populateDeviceSettings];			
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
		populateTrackItInstanceArrayRetryCount = 0;
		[self populateTrackItInstanceArray];
		// get service side app settings
		populateIPhoneAppSettingsRetryCount = 0;
		[self populateDeviceSettings];	
		// load device blacklist info
		populateDeviceBlackListInfoRetryCount = 0;
		[self populateDeviceBlackListInfo];
		return;
	}
	if ([requestType isEqualToString:@"check_blacklist"]) {
		[self parseDeviceBlackListXml:responseString andHttpResponseCode:request.responseStatusCode];
		return;
	}	
	if ([requestType isEqualToString:@"get_instances"]) {
		[self parseTrackItInstanceXml:responseString andHttpResponseCode:request.responseStatusCode];
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
		[self retryPopulateTrackItInstanceArray];
	}
	if ([requestType isEqualToString:@"app_settings"]) {
		[self retryPopulateDeviceSettings];
	}
}

@end

