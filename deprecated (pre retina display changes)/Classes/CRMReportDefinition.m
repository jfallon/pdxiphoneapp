//
//  TrackItInstance.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/22/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "CRMReportDefinition.h"


@implementation CRMReportDefinition

@synthesize number;
@synthesize category;
@synthesize imageRequired;
@synthesize addressRequired;
@synthesize commentsRequired;
@synthesize instanceName;
@synthesize imageFieldName;
@synthesize commentsFieldName;
@synthesize addressFieldName;
@synthesize xCoordFieldName;
@synthesize yCoordFieldName;
@synthesize instanceMessage;

- (void)dealloc {
	
	[instanceName release]; instanceName = nil;
	[imageFieldName release]; imageFieldName = nil;
	[commentsFieldName release]; commentsFieldName = nil;
	[addressFieldName release]; addressFieldName = nil;
	[xCoordFieldName release]; xCoordFieldName = nil;
	[yCoordFieldName release]; yCoordFieldName = nil;
	[instanceMessage release]; instanceMessage = nil;
	[super dealloc];
}

@end
