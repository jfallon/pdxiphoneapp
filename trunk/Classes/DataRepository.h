//
//  DataRepository.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/23/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

//#import <Foundation/Foundation.h>

@class Report;
@class CLLocation;
@class AppSettings;
@class Reachability;
@class PDXBoundary;

@interface DataRepository : NSObject {
	
	NSMutableArray *crmReportDefinitionArray;
	NSMutableArray *userReportArray;
	NSDictionary *statusCodeDictionary;
	CLLocation *proposedLocation;		
	Reachability *reachabilityInternet;
	Reachability *reachabilityHost;
	
	PDXBoundary *boundary;
	
	NSString *verifyValue;
	NSString *blackListReason;
	NSString *deviceID;	
	NSString *documentsFolder;
	NSString *unsentReportFilePath;	
	NSString *appSettingsFilePath;
	
	Report *unsentReport;
	Report *selectedReport;
	AppSettings *appSettings;
	
	NSString *urlPrefix;
	NSString *getServerSettingsUrlSuffix;
	NSString *getAppSettingsUrlSuffix;
	NSString *getBlacklistStatusUrlSuffix;
	NSString *getReportDefinitionsUrlSuffix;
	NSString *getAllMyItemsUrlSuffix;
	NSString *sendContactInfoUrlSuffix;
	NSString *sendUserReportToCRMUrlSuffix;
	NSString *pingServerUrlSuffix;
	NSString *getItemPhotoUrlSuffix;
	NSString *getItemMapUrlSuffix;
	
	NSString *getItemDetailUrlSuffix;
	NSString *getItemDetailUrlParameters;

	bool deviceIsBlackListed;
	bool internetIsReachable;
	bool connectionRequiredForInternet;
	bool hostIsReachable;
	
	bool blackListWasLoaded;
	bool reportTypesWereLoaded;
	bool serverSettingsWereLoaded;
	bool deviceSettingsWereLoaded;
	
	double latitudeSouth;
	double latitudeNorth;
	double longitudeWest;
	double longitudeEast;
	double latitudeCenter;
	double longitudeCenter;
	bool myReportsShouldBeRefreshed;

	UITabBarController *tabBarController;
}

extern NSString * const NOTIF_AppComingToForeground;

+ (DataRepository *)sharedInstance;

@property (nonatomic, copy)		NSString *urlPrefix;
@property (nonatomic, readonly) NSString *getServerSettingsUrlSuffix;
@property (nonatomic, readonly) NSString *getAppSettingsUrlSuffix;
@property (nonatomic, readonly) NSString *getBlacklistStatusUrlSuffix;
@property (nonatomic, readonly) NSString *getReportDefinitionsUrlSuffix;
@property (nonatomic, readonly) NSString *getAllMyItemsUrlSuffix;
@property (nonatomic, readonly) NSString *sendContactInfoUrlSuffix;
@property (nonatomic, readonly) NSString *sendUserReportToCRMUrlSuffix;
@property (nonatomic, readonly) NSString *pingServerUrlSuffix;
@property (nonatomic, readonly) NSString *getItemDetailUrlSuffix;
@property (nonatomic, retain)	NSString *getItemDetailUrlParameters;
@property (nonatomic, retain)	NSString *getItemPhotoUrlSuffix;
@property (nonatomic, retain)	NSString *getItemMapUrlSuffix;

@property (nonatomic, readonly) PDXBoundary *boundary;

@property (nonatomic,retain)	NSMutableArray *crmReportDefinitionArray;
@property (nonatomic,retain)	NSMutableArray *userReportArray;
@property (nonatomic,retain)	NSDictionary *statusCodeDictionary;
@property (nonatomic,readonly)	NSString *verifyValue;
@property (nonatomic,retain)	AppSettings *appSettings;
@property (nonatomic,copy)		NSString *appSettingsFilePath;

@property (nonatomic,copy)		NSString *blackListReason;
@property (nonatomic,readonly)	NSString *deviceID;
@property (nonatomic,copy)		NSString *documentsFolder;
@property (nonatomic,copy)		NSString *unsentReportFilePath;
@property (nonatomic,retain)	Report *unsentReport;
@property (nonatomic,retain)	Report *selectedReport;
@property (nonatomic,copy)		CLLocation *proposedLocation;
@property (nonatomic,retain)	Reachability *reachabilityInternet;
@property (nonatomic,retain)	Reachability *reachabilityHost;

@property (readonly) double latitudeSouth;
@property (readonly) double latitudeNorth;
@property (readonly) double longitudeWest;
@property (readonly) double longitudeEast;
@property (readonly) double latitudeCenter;
@property (readonly) double longitudeCenter;

@property			 bool   deviceIsBlackListed;
@property			 bool   internetIsReachable;
@property			 bool   connectionRequiredForInternet;
@property			 bool   hostIsReachable;
@property			 bool   myReportsShouldBeRefreshed;

@property			 bool   blackListWasLoaded;
@property			 bool   reportTypesWereLoaded;
@property			 bool   serverSettingsWereLoaded;
@property			 bool   deviceSettingsWereLoaded;

@property(nonatomic,retain) IBOutlet UITabBarController *tabBarController;

- (bool)locationIsInCity:(CLLocation *)location;
- (void)switchActiveTab:(NSUInteger)selectedIndex;
- (bool)internetIsReachableRightNow;
- (void)internetReachabilityHasChanged:(NSNotification *)notice;
- (void)hostReachabilityHasChanged:(NSNotification *)notice;
- (bool)stringContains:(NSString *)stringToSearch subString:(NSString *)stringToFind;

@end
