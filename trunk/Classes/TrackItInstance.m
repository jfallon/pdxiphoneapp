//
//  TrackItInstance.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "TrackItInstance.h"


@implementation TrackItInstance

@synthesize number;
@synthesize category;
@synthesize imageRequired;
@synthesize addressRequired;
@synthesize commentsRequired;
@synthesize instanceName;
@synthesize imageInputName;
@synthesize commentsInputName;
@synthesize addressStringInputName;
@synthesize addressXInputName;
@synthesize addressYInputName;
@synthesize instanceMessage;

- (void)dealloc {
	
	[instanceName release]; instanceName = nil;
	[imageInputName release]; imageInputName = nil;
	[commentsInputName release]; commentsInputName = nil;
	[addressStringInputName release]; addressStringInputName = nil;
	[addressXInputName release]; addressXInputName = nil;
	[addressYInputName release]; addressYInputName = nil;
	[instanceMessage release]; instanceMessage = nil;
	[super dealloc];
}

@end
