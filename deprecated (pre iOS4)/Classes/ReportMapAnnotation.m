//
//  ReportAnnotation.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/4/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "ReportMapAnnotation.h"


@implementation ReportMapAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (void)dealloc {
	[title release]; title = nil;
	[subtitle release]; subtitle = nil;
	[super dealloc];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
	self = [super init];
	if (self != nil) {
		coordinate = coord;
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)newTitle andSubtitle:(NSString *)newSubtitle {
	self = [super init];
	if (self != nil) {
		coordinate = coord;
		[self setTitle:newTitle];
		[self setSubtitle:newSubtitle];
    }
    return self;
}

-(void)changeCoordinate:(CLLocationCoordinate2D)coord {
	coordinate = coord;
}

@end
