//
//  ReportMapAnnotationView.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ReportMapAnnotationView : MKAnnotationView {

    BOOL isMoving;
    CGPoint startLocation;
    CGPoint originalCenter;
    MKMapView* map;
}

@property (assign, nonatomic) MKMapView* map;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end