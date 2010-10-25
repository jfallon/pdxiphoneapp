//
//  LocationPin.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/18/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "LocationPin.h"


@implementation LocationPin

@synthesize coordinate = _coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	self = [super init];
	if (self != nil){
		_coordinate = coordinate;
	}
	return self;
}

@end
