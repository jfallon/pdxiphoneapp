//
//  DisplayLocationViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/16/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DisplayLocationViewController : UIViewController {
	IBOutlet MKMapView *mapView;
	MKCoordinateRegion _region;
	CLLocationCoordinate2D _location;
}

@property(nonatomic,retain) IBOutlet MKMapView *mapView;


- (id)initWithRegion:(MKCoordinateRegion)region fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil;
- (id)initWithRegion:(MKCoordinateRegion)region andPinLocation:(CLLocationCoordinate2D)coordinate fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil;

@end
