//
//  Report.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "Report.h"


@implementation Report

@synthesize image;
@synthesize imageID;
@synthesize number;
@synthesize reportType;
@synthesize comments;
@synthesize longitude;
@synthesize latitude;
@synthesize horizontalAccuracyInMeters;
@synthesize streetAddress;
@synthesize creationDate;
@synthesize status;
@synthesize lastUpdate;
@synthesize customStatus;

- (void)dealloc {
	[image release]; image = nil;
	[reportType release]; reportType = nil;
	[comments release]; comments = nil;
	[streetAddress release]; streetAddress = nil;
	[creationDate release]; creationDate = nil;
	[status release]; status = nil;
	[lastUpdate release]; lastUpdate = nil;
	[customStatus release]; customStatus = nil;
	[super dealloc];
}

// implementation methods for NSCoding protocol, which allows for objects to serialize/deserialize
- (void)encodeWithCoder:(NSCoder *)encoder {
	//default serialization
	[encoder encodeInteger:imageID forKey:@"ImageID"];
	[encoder encodeInteger:number forKey:@"Number"];
	[encoder encodeObject:reportType forKey:@"ReportType"];
	[encoder encodeObject:comments forKey:@"Comments"];
	[encoder encodeObject:streetAddress forKey:@"Address"];
	[encoder encodeObject:creationDate forKey:@"CreationDate"];
	[encoder encodeObject:status forKey:@"Status"];
	[encoder encodeObject:lastUpdate forKey:@"LastUpdate"];
	[encoder encodeObject:customStatus forKey:@"CustomStatus"];
	//image needs to be handled a bit differently
	NSData *imageData = UIImagePNGRepresentation(image);
	[encoder encodeObject:imageData forKey:@"Image"];
}
- (id)initWithCoder:(NSCoder *)decoder {
	//default de-serialization
	[self setImageID:[decoder decodeIntegerForKey:@"ImageID"]];
	[self setNumber:[decoder decodeIntegerForKey:@"Number"]];
	[self setReportType:[decoder decodeObjectForKey:@"ReportType"]];
	[self setComments:[decoder decodeObjectForKey:@"Comments"]];
	[self setLatitude:0];
	[self setLongitude:0];
	[self setHorizontalAccuracyInMeters:0];
	[self setStreetAddress:[decoder decodeObjectForKey:@"Address"]];
	[self setCreationDate:[decoder decodeObjectForKey:@"CreationDate"]];
	[self setStatus:[decoder decodeObjectForKey:@"Status"]];
	[self setLastUpdate:[decoder decodeObjectForKey:@"LastUpdate"]];
	[self setCustomStatus:[decoder decodeObjectForKey:@"CustomStatus"]];
	//image needs to be handled a bit differently
	NSData *imageData = [decoder decodeObjectForKey:@"Image"];
	[self setImage:[UIImage imageWithData:imageData]];
	return self;
}
@end
