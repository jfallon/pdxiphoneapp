//
//  LocationPin.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/18/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationPin : NSObject <MKAnnotation> {
	CLLocationCoordinate2D _coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
