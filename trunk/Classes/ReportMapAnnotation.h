//
//  ReportAnnotation.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/4/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ReportMapAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coord andTitle:(NSString *)newTitle andSubtitle:(NSString *)newSubtitle;

-(void)changeCoordinate:(CLLocationCoordinate2D)coord;

@end
