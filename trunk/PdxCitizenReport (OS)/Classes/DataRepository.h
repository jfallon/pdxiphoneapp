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
	
    NSString *agencyName;
    NSString *agencyPhoneNumber;
    NSString *agencyEmailAddress;
    NSString *appName;
    
	NSMutableArray *crmReportDefinitionArray;
	NSMutableArray *userReportArray;
    NSArray *statusCodeKeys;
    NSArray *statusCodeValues;
    NSMutableArray *statusCodeIsToggledOn;
	CLLocation *proposedLocation;		
	Reachability *reachabilityInternet;
	Reachability *reachabilityHost;
	
	PDXBoundary *boundary;
	
	NSString *verifyValue;
	NSString *blackListReason;
	NSString *documentsFolder;
	NSString *unsentReportFilePath;	
	NSString *appSettingsFilePath;
	
	NSString *deviceID;	
	NSString *deviceManufacturer;
	NSString *deviceModel;
	NSString *deviceOsName;
	NSString *deviceOsVersion;
	
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
	double numberOfSecondsBackgrounded;

	UITabBarController *tabBarController;
}

extern NSString * const NOTIF_AppComingToForeground;

+ (DataRepository *)sharedInstance;

@property (nonatomic,readonly)  NSString *agencyName;
@property (nonatomic,readonly)  NSString *agencyPhoneNumber;
@property (nonatomic,readonly)  NSString *agencyEmailAddress;
@property (nonatomic,readonly)  NSString *appName;

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
@property (nonatomic,retain)    NSArray *statusCodeKeys;
@property (nonatomic,retain)    NSArray *statusCodeValues;
@property (nonatomic,retain)    NSMutableArray *statusCodeIsToggledOn;
@property (nonatomic,readonly)	NSString *verifyValue;
@property (nonatomic,retain)	AppSettings *appSettings;
@property (nonatomic,copy)		NSString *appSettingsFilePath;

@property (nonatomic,copy)		NSString *blackListReason;
@property (nonatomic,copy)		NSString *documentsFolder;
@property (nonatomic,copy)		NSString *unsentReportFilePath;
@property (nonatomic,retain)	Report *unsentReport;
@property (nonatomic,retain)	Report *selectedReport;
@property (nonatomic,copy)		CLLocation *proposedLocation;
@property (nonatomic,retain)	Reachability *reachabilityInternet;
@property (nonatomic,retain)	Reachability *reachabilityHost;

@property (nonatomic,readonly)	NSString *deviceID;
@property (nonatomic,readonly)	NSString *deviceManufacturer;
@property (nonatomic,readonly)	NSString *deviceModel;
@property (nonatomic,readonly)	NSString *deviceOsName;
@property (nonatomic,readonly)	NSString *deviceOsVersion;

@property (readonly) double latitudeSouth;
@property (readonly) double latitudeNorth;
@property (readonly) double longitudeWest;
@property (readonly) double longitudeEast;
@property (readonly) double latitudeCenter;
@property (readonly) double longitudeCenter;
@property			 double numberOfSecondsBackgrounded;

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
- (NSUInteger)getActiveTabIndex;
- (bool)internetIsReachableRightNow;
- (void)internetReachabilityHasChanged:(NSNotification *)notice;
- (void)hostReachabilityHasChanged:(NSNotification *)notice;
- (bool)stringContains:(NSString *)stringToSearch subString:(NSString *)stringToFind;
- (NSString *)getReportStatusFilterString;
- (NSString *)getCategoryFilterString;
- (bool)categoryIsVisible:(NSString *)name;
- (bool)emailAddressIsValid:(NSString *)candidate;
- (bool)stringIsUnsignedInt:(NSString *)candidate;

@end
