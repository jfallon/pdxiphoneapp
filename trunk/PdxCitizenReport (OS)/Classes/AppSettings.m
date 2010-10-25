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
@synthesize lastNagForContactInfoDate;

- (void)dealloc {
	[userName release]; userName = nil;
	[userEmailAddress release]; userEmailAddress = nil;
	[userTelephoneNumber release]; userTelephoneNumber = nil;
	[helpPageAddress release]; helpPageAddress = nil;
	[usageWarningText release]; usageWarningText = nil;
	[lastNagForContactInfoDate release]; lastNagForContactInfoDate = nil;
	[super dealloc];
}

@end
