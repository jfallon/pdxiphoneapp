//
//  AppSettings.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/12/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
	[encoder encodeObject:userName forKey:@"FullName"];
	[encoder encodeObject:userEmailAddress forKey:@"Email"];
	[encoder encodeObject:userTelephoneNumber forKey:@"PhoneNumber"];
	[encoder encodeObject:helpPageAddress forKey:@"HelpPageURL"];
	[encoder encodeObject:usageWarningText forKey:@"WarningText"];
}
- (id)initWithCoder:(NSCoder *)decoder {
	//default de-serialization
	[self setUserName:[decoder decodeObjectForKey:@"FullName"]];
	[self setUserEmailAddress:[decoder decodeObjectForKey:@"Email"]];
	[self setUserTelephoneNumber:[decoder decodeObjectForKey:@"PhoneNumber"]];
	[self setHelpPageAddress:[decoder decodeObjectForKey:@"HelpPageURL"]];
	[self setUsageWarningText:[decoder decodeObjectForKey:@"WarningText"]];
	return self;
}

@end
