//
//  AppSettings.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/12/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppSettings : NSObject {
	NSInteger	usageWarningCounter;
	NSInteger	usageWarningInterval;
	double		requiredGPSAccuracyInMeters;
	NSInteger	photoLargestSideInPixels;
	float		jpegCompressionFactor;
	NSInteger	gpsSampleIntervalInSeconds;
	NSInteger	gpsSampleCount;
	NSString	*userName;
	NSString	*userEmailAddress;
	NSString	*userTelephoneNumber;
	bool		userSettingsApplied;
	NSString	*helpPageAddress;
	NSString	*usageWarningText;
	NSDate		*lastNagForContactInfoDate;
}

@property(nonatomic)		NSInteger usageWarningCounter;
@property(nonatomic)		NSInteger usageWarningInterval;
@property(nonatomic)		double requiredGPSAccuracyInMeters;
@property(nonatomic)		float jpegCompressionFactor;
@property(nonatomic)		NSInteger photoLargestSideInPixels;
@property(nonatomic)		NSInteger gpsSampleIntervalInSeconds;
@property(nonatomic)		NSInteger gpsSampleCount;
@property(nonatomic)		bool userSettingsApplied;
@property(nonatomic,copy)	NSString *userName;
@property(nonatomic,copy)	NSString *userEmailAddress;
@property(nonatomic,copy)	NSString *userTelephoneNumber;
@property(nonatomic,copy)	NSString *helpPageAddress;
@property(nonatomic,copy)	NSString *usageWarningText;
@property(nonatomic,copy)	NSDate *lastNagForContactInfoDate;

@end
