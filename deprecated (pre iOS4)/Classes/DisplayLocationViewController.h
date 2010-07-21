//
//  DisplayLocationViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
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
