//
//  AppSettings.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "AppSettings.h"


@implementation AppSettings

@synthesize usageWarningCounter;
@synthesize usageWarningInterval;
@synthesize requiredGPSAccuracyInMeters;
@synthesize photoLargestSideInPixels;
@synthesize jpegCompressionFactor;
@synthesize gpsSampleIntervalInSeconds;
@synthesize gpsSampleCount;
@synthesize userSettingsApplied;
@synthesize userName;
@synthesize userEmailAddress;
@synthesize userTelephoneNumber;
@synthesize helpPageAddress;
@synthesize usageWarningText;

- (void)dealloc {
	[userName release]; userName = nil;
	[userEmailAddress release]; userEmailAddress = nil;
	[userTelephoneNumber release]; userTelephoneNumber = nil;
	[helpPageAddress release]; helpPageAddress = nil;
	[usageWarningText release]; usageWarningText = nil;
	[super dealloc];
}

// implementation methods for NSCoding protocol, which allows for objects to serialize/deserialize into a binary file
- (void)encodeWithCoder:(NSCoder *)encoder {
	//default serialization
	[encoder encodeInteger:usageWarningCounter forKey:@"WarningCounter"];
	[encoder encodeInteger:usageWarningInterval forKey:@"WarningInterval"];
//	[encoder encodeDouble:requiredGPSAccuracyInMeters forKey:@"Accuracy"];
//	[encoder encodeInteger:photoLargestSideInPixels forKey:@"PhotoResolution"];
//	[encoder encodeFloat:jpegCompressionFactor forKey:@"JpegCompression"];
//	[encoder encodeInteger:gpsSampleIntervalInSeconds forKey:@"GpsSampleInterval"];
//	[encoder encodeInteger:gpsSampleCount forKey:@"GpsSampleCount"];
	[encoder encodeObject:userName forKey:@"FullName"];
	[encoder encodeObject:userEmailAddress forKey:@"Email"];
	[encoder encodeObject:userTelephoneNumber forKey:@"PhoneNumber"];
	[encoder encodeObject:helpPageAddress forKey:@"HelpPageURL"];
	[encoder encodeObject:usageWarningText forKey:@"WarningText"];
}
- (id)initWithCoder:(NSCoder *)decoder {
	//default de-serialization
	usageWarningCounter = [decoder decodeIntegerForKey:@"WarningCounter"];
	usageWarningInterval = [decoder decodeIntegerForKey:@"WarningInterval"];
//	requiredGPSAccuracyInMeters = [decoder decodeDoubleForKey:@"Accuracy"];
//	photoLargestSideInPixels = [decoder decodeIntegerForKey:@"PhotoResolution"];
//	jpegCompressionFactor = [decoder decodeFloatForKey:@"JpegCompression"];
//	gpsSampleIntervalInSeconds = [decoder decodeIntegerForKey:@"GpsSampleInterval"];
//	gpsSampleCount = [decoder decodeIntegerForKey:@"GpsSampleCount"];
	[self setUserName:[decoder decodeObjectForKey:@"FullName"]];
	[self setUserEmailAddress:[decoder decodeObjectForKey:@"Email"]];
	[self setUserTelephoneNumber:[decoder decodeObjectForKey:@"PhoneNumber"]];
	[self setHelpPageAddress:[decoder decodeObjectForKey:@"HelpPageURL"]];
	[self setUsageWarningText:[decoder decodeObjectForKey:@"WarningText"]];
	return self;
}

@end
