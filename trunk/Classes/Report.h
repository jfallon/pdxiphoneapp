//
//  Report.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

//#import <Foundation/Foundation.h>


@interface Report : NSObject <NSCoding> {
	
	UIImage *image;
	NSInteger imageID;
	NSInteger number;
	NSString *reportType;
	NSString *comments;
	double longitude;
	double latitude;
	double horizontalAccuracyInMeters;
	NSString *streetAddress;
	NSDate *creationDate;
	NSString *status;
	NSString *lastUpdate;
	NSString *customStatus;
}

@property(nonatomic,retain) UIImage *image;
@property NSInteger imageID;
@property NSInteger number;
@property(nonatomic,copy) NSString *reportType;
@property(nonatomic,copy) NSString *comments;
@property double longitude;
@property double latitude;
@property double horizontalAccuracyInMeters;
@property(nonatomic,copy) NSString *streetAddress;
@property(nonatomic,copy) NSDate *creationDate;
@property(nonatomic,copy) NSString *status;
@property(nonatomic,copy) NSString *lastUpdate;
@property(nonatomic,copy) NSString *customStatus;

// NSCoding protocol for object serialization/deserialization
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)encoder;

@end
