//
//  DataRepository.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

//#import <Foundation/Foundation.h>

@class Report;
@class CLLocation;
@class AppSettings;
@class Reachability;
@class PdxBoundary;

@interface DataRepository : NSObject {
	
	NSMutableArray *trackItInstanceArray;
	NSMutableArray *userReportArray;
	NSDictionary *statusCodeDictionary;
	CLLocation *proposedLocation;		
	Reachability *reachabilityInternet;
	Reachability *reachabilityHost;
	
	PdxBoundary *boundary;
	
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
	NSString *getTrackItInstancesUrlSuffix;
	NSString *getAllMyItemsUrlSuffix;
	NSString *sendContactInfoUrlSuffix;
	NSString *sendReportToTrackItUrlSuffix;
	NSString *pingServerUrlSuffix;
	NSString *getItemPhotoUrlSuffix;
	NSString *getItemMapUrlSuffix;
	
	NSString *getItemDetailUrlSuffix;
	NSString *getItemDetailUrlParameters;

	bool deviceIsBlackListed;
	bool internetIsReachable;
	bool connectionRequiredForInternet;
	bool hostIsReachable;
	
	double latitudeSouth;
	double latitudeNorth;
	double longitudeWest;
	double longitudeEast;
	double latitudeCenter;
	double longitudeCenter;
	bool myReportsShouldBeRefreshed;

	UITabBarController *tabBarController;
}

+ (DataRepository *)sharedInstance;

@property (nonatomic, copy)		NSString *urlPrefix;
@property (nonatomic, readonly) NSString *getServerSettingsUrlSuffix;
@property (nonatomic, readonly) NSString *getAppSettingsUrlSuffix;
@property (nonatomic, readonly) NSString *getBlacklistStatusUrlSuffix;
@property (nonatomic, readonly) NSString *getTrackItInstancesUrlSuffix;
@property (nonatomic, readonly) NSString *getAllMyItemsUrlSuffix;
@property (nonatomic, readonly) NSString *sendContactInfoUrlSuffix;
@property (nonatomic, readonly) NSString *sendReportToTrackItUrlSuffix;
@property (nonatomic, readonly) NSString *pingServerUrlSuffix;
@property (nonatomic, readonly) NSString *getItemDetailUrlSuffix;
@property (nonatomic, retain)	NSString *getItemDetailUrlParameters;
@property (nonatomic, retain)	NSString *getItemPhotoUrlSuffix;
@property (nonatomic, retain)	NSString *getItemMapUrlSuffix;

@property (nonatomic, readonly) PdxBoundary *boundary;

@property (nonatomic,retain)	NSMutableArray *trackItInstanceArray;
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

@property(nonatomic,retain) IBOutlet UITabBarController *tabBarController;

- (bool)locationIsInCity:(CLLocation *)location;
- (void)switchActiveTab:(NSUInteger)selectedIndex;
- (bool)internetIsReachableRightNow;
- (void)internetReachabilityHasChanged:(NSNotification *)notice;
- (void)hostReachabilityHasChanged:(NSNotification *)notice;
- (bool)stringContains:(NSString *)stringToSearch subString:(NSString *)stringToFind;

@end
