//
//  PdxCitizenReportAppDelegate.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;
//@class Reachability;

@interface PdxCitizenReportAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    
	UIWindow *window;
    UITabBarController *tabBarController;
	
	NSInteger populateIPhoneServerSettingsRetryCount;
	NSInteger populateDeviceBlackListInfoRetryCount;
	NSInteger populateTrackItInstanceArrayRetryCount;
	NSInteger populateIPhoneAppSettingsRetryCount;	
}

@property(nonatomic,retain) IBOutlet UIWindow *window;
@property(nonatomic,retain) IBOutlet UITabBarController *tabBarController;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (void)populateTrackItInstanceArray;
- (void)retryPopulateTrackItInstanceArray;
- (void)parseTrackItInstanceXml:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateDeviceBlackListInfo;
- (void)retryPopulateDeviceBlackListInfo;
- (void)parseDeviceBlackListXml:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateDeviceSettings;
- (void)retryPopulateDeviceSettings;
- (void)parseDeviceSettings:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateServerSettings;
- (void)retryPopulateServerSettings;
- (void)parseServerSettings:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)saveUnsentReport;
- (void)loadUnsentReport;

- (void)saveAppSettings;
- (void)loadAppSettings;

@end
