//
//  DataRepository.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/23/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DataRepository.h"
#import "Report.h"
#import "AppSettings.h"
#import "Reachability.h"
#import "PDXBoundary.h"

NSString * const NOTIF_AppComingToForeground = @"AppComingToForeground";

@implementation DataRepository

static DataRepository *sharedInstance = nil;

@synthesize crmReportDefinitionArray;
@synthesize userReportArray;
@synthesize statusCodeDictionary;
@synthesize verifyValue;
@synthesize appSettings;
@synthesize appSettingsFilePath;
@synthesize urlPrefix;
@synthesize getServerSettingsUrlSuffix;
@synthesize getAppSettingsUrlSuffix;
@synthesize getBlacklistStatusUrlSuffix;
@synthesize getReportDefinitionsUrlSuffix;
@synthesize getAllMyItemsUrlSuffix;
@synthesize sendContactInfoUrlSuffix;
@synthesize sendUserReportToCRMUrlSuffix;
@synthesize pingServerUrlSuffix;
@synthesize getItemDetailUrlSuffix;
@synthesize getItemDetailUrlParameters;
@synthesize getItemPhotoUrlSuffix;
@synthesize getItemMapUrlSuffix;
@synthesize boundary;
@synthesize deviceIsBlackListed;
@synthesize myReportsShouldBeRefreshed;
@synthesize blackListReason;
@synthesize deviceID;
@synthesize deviceManufacturer;
@synthesize deviceModel;
@synthesize deviceOsName;
@synthesize deviceOsVersion;
@synthesize internetIsReachable;
@synthesize connectionRequiredForInternet;
@synthesize hostIsReachable;
@synthesize documentsFolder;
@synthesize unsentReportFilePath;
@synthesize unsentReport;
@synthesize selectedReport;
@synthesize proposedLocation;
@synthesize latitudeSouth;
@synthesize latitudeNorth;
@synthesize longitudeWest;
@synthesize longitudeEast;
@synthesize latitudeCenter;
@synthesize longitudeCenter;
@synthesize numberOfSecondsBackgrounded;
@synthesize tabBarController;
@synthesize reachabilityInternet;
@synthesize reachabilityHost;
@synthesize blackListWasLoaded;
@synthesize reportTypesWereLoaded;
@synthesize serverSettingsWereLoaded;
@synthesize deviceSettingsWereLoaded;

+ (DataRepository *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
			sharedInstance = [[DataRepository alloc] init]; 
		}
    }
    return sharedInstance;
}

-(id) init {
	
	self = [super init];
    if (self != nil) {
		
		UIDevice *device = [UIDevice currentDevice];
		deviceID = [[device uniqueIdentifier] retain];
		deviceManufacturer = @"Apple";
		deviceModel = [[device model] retain];
		deviceOsName = [[device systemName] retain];
		deviceOsVersion = [[device systemVersion] retain];
		
		// location dependent - current values represents a rough envelope around Portland, OR
		latitudeSouth = 45.45380;
		latitudeNorth = 45.64952;
		longitudeWest = -122.82337;
		longitudeEast = -122.49682;

		// location dependent - current values represents a rough center of Portland, OR
		longitudeCenter = -122.64770;
		latitudeCenter = 45.53162;
		//latitudeCenter = (latitudeSouth + ((latitudeNorth - latitudeSouth) / 2));
		//longitudeCenter = (longitudeWest - ((longitudeWest - longitudeEast) / 2));

		boundary = [[PDXBoundary alloc]init]; 
		
		reachabilityHost = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
		
		reachabilityInternet = [[Reachability reachabilityForInternetConnection] retain];
		NetworkStatus internetStatus = [reachabilityInternet currentReachabilityStatus];		
		connectionRequiredForInternet = [reachabilityInternet connectionRequired];
		if (internetStatus == NotReachable) {
			self.internetIsReachable = NO; 
			self.connectionRequiredForInternet = NO;
		} 
		else {
			self.internetIsReachable = YES;
		}
		// now subscribe to changes in internet connectivity
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(internetReachabilityHasChanged:) name:kReachabilityChangedNotification object:nil];
		[reachabilityInternet startNotifier];
		
		NetworkStatus hostStatus = [reachabilityHost currentReachabilityStatus];
		if (hostStatus == NotReachable) {
			self.hostIsReachable = NO;
		}
		else {
			self.hostIsReachable = YES;
		}

		// now subscribe to changes in host connectivity
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostReachabilityHasChanged:) name:kHostReachabilityChangedNotification object:nil];
		[reachabilityHost startNotifier];		
		
		// default app settings that can be used if server-side values are unavailable for some reason
		//appSettings = [[[AppSettings alloc] init] retain];
		appSettings = [[AppSettings alloc] init];
		appSettings.requiredGPSAccuracyInMeters = 20;
		appSettings.photoLargestSideInPixels = 800;
		appSettings.jpegCompressionFactor = 0.5;
		appSettings.gpsSampleCount = 7;
		appSettings.gpsSampleIntervalInSeconds = 3;
		appSettings.usageWarningCounter = 0;
		appSettings.usageWarningInterval = 1;
		appSettings.usageWarningText = @"some warning text goes here";		
		unsentReport = [[[Report alloc]init] retain];
		
		deviceIsBlackListed = NO;
		blackListReason = nil;
		myReportsShouldBeRefreshed = YES;
		
		// site dependant, used as password for POST operations to CRM
		verifyValue = @"some value goes here";
		[verifyValue retain];
				
		// default values for URLs if for some reason they aren't available dynamically
		urlPrefix = @"http://some.website.com";
		[urlPrefix retain];	
		getServerSettingsUrlSuffix = @"/some/app/domain/deviceserver.script";
		[getServerSettingsUrlSuffix retain];
		getAppSettingsUrlSuffix = @"/some/app/domain/dsettings.script";
		[getAppSettingsUrlSuffix retain];
		getBlacklistStatusUrlSuffix = @"/some/app/domain/blacklist.script";
		[getBlacklistStatusUrlSuffix retain];		
		getReportDefinitionsUrlSuffix = @"/some/app/domain/iphone.script";
		[getReportDefinitionsUrlSuffix retain];
		getAllMyItemsUrlSuffix = @"/some/app/domain/device.script";
		[getAllMyItemsUrlSuffix retain];
		sendContactInfoUrlSuffix = @"/some/app/domain/devicecontact.script";
		[sendContactInfoUrlSuffix retain];
		sendUserReportToCRMUrlSuffix = @"/some/app/domain/input.script";
		[sendUserReportToCRMUrlSuffix retain];
		pingServerUrlSuffix = @"/some/app/domain/ping.script";
		[pingServerUrlSuffix retain];
		getItemDetailUrlSuffix = @"/some/app/domain/deviceitem.script";
		[getItemDetailUrlSuffix retain];
		getItemPhotoUrlSuffix = @"/some/app/domain/deviceimage.script";
		[getItemPhotoUrlSuffix retain];
		getItemMapUrlSuffix = @"/some/app/domain/devicemap.v";
		[getItemMapUrlSuffix retain];
		
		crmReportDefinitionArray = [[NSMutableArray array] retain];
		userReportArray = [[NSMutableArray array] retain];
		
		// default status code equivalents in Portland's CRM
		NSArray *keys = [NSArray arrayWithObjects:@"O", @"W", @"R", @"C", @"A", nil];
		NSArray *objects = [NSArray arrayWithObjects:@"Open", @"Work in Progess", @"Referred", @"Closed", @"Archived", nil];
		statusCodeDictionary = [[NSDictionary dictionaryWithObjects:objects forKeys:keys] retain];
		
    }
    return self;
}

- (bool)internetIsReachableRightNow {
	NetworkStatus internetStatus = [reachabilityInternet currentReachabilityStatus];
	self.connectionRequiredForInternet = [reachabilityInternet connectionRequired];
	if (internetStatus == NotReachable) {
		self.connectionRequiredForInternet = NO;
		self.internetIsReachable = NO;
	} 
	else {
		self.internetIsReachable = YES;
	}
	return internetIsReachable;
}
	
- (void)internetReachabilityHasChanged:(NSNotification *)notice {
	NetworkStatus internetStatus = [reachabilityInternet currentReachabilityStatus];
	self.connectionRequiredForInternet = [reachabilityInternet connectionRequired];
	if (internetStatus == NotReachable) {
		self.internetIsReachable = NO; 
		self.connectionRequiredForInternet = NO;
	} else {
		self.internetIsReachable = YES; 
	}
}

- (void)hostReachabilityHasChanged:(NSNotification *)notice {
	NetworkStatus hostStatus = [reachabilityHost currentReachabilityStatus];
	if (hostStatus == NotReachable) {
		self.hostIsReachable = NO;
	}
	else {
		self.hostIsReachable = YES;
	}
}

- (void)switchActiveTab:(NSUInteger)selectedIndex {
	if (tabBarController != nil) {
		[tabBarController setSelectedIndex:selectedIndex];
	}
}
- (NSUInteger)getActiveTabIndex {
	if (tabBarController != nil) {
		return [tabBarController selectedIndex];
	} else {
		return -1;
	}
}


- (bool)locationIsInCity:(CLLocation *)location {
	return [boundary locationIsInside:location];
}

- (bool)stringContains:(NSString *)stringToSearch subString:(NSString *)stringToFind {
	if (stringToFind == nil || stringToSearch == nil) {
		return NO;
	}
	NSRange range = [stringToSearch rangeOfString:stringToFind];
	if (range.location == NSNotFound) {
		return NO;
	}
	else {
		return YES;
	}
}


@end
