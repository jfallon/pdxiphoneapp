//
//  PdxCitizenReportAppDelegate.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright City of Portland 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;


@interface PdxCitizenReportAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    
	UIWindow *window;
    UITabBarController *tabBarController;
	NSDate *timeBackgrounded;
	
	NSInteger populateIPhoneServerSettingsRetryCount;
	NSInteger populateDeviceBlackListInfoRetryCount;
	NSInteger populateTrackItInstanceArrayRetryCount;
	NSInteger populateIPhoneAppSettingsRetryCount;	
}

@property(nonatomic,retain) IBOutlet UIWindow *window;
@property(nonatomic,retain) IBOutlet UITabBarController *tabBarController;
@property(nonatomic,retain) NSDate *timeBackgrounded;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (void)populateReportTypeArray:(bool)resetRetryCounter;
- (void)retryPopulateReportTypeArray;
- (void)parseReportTypeXml:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateDeviceBlackListInfo:(bool)resetRetryCounter;
- (void)retryPopulateDeviceBlackListInfo;
- (void)parseDeviceBlackListXml:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateDeviceSettings:(bool)resetRetryCounter;
- (void)retryPopulateDeviceSettings;
- (void)parseDeviceSettings:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)populateServerSettings:(bool)resetRetryCounter;
- (void)retryPopulateServerSettings;
- (void)parseServerSettings:(NSString *)xmlData andHttpResponseCode:(int)code;

- (void)saveUnsentReport;
- (void)loadUnsentReport;

- (void)saveAppSettings;
- (void)loadAppSettings;

@end
