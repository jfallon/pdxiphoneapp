//
//  AppSettings.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import <Foundation/Foundation.h>


@interface AppSettings : NSObject <NSCoding> {
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

// NSCoding protocol for object serialization/deserialization
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)encoder;

@end
