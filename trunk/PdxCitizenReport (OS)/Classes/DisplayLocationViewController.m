//
//  DisplayLocationViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/16/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "DisplayLocationViewController.h"
#import "LocationPin.h"

@implementation DisplayLocationViewController

@synthesize mapView;

- (id)initWithRegion:(MKCoordinateRegion)region fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil {

	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		_region = region;
	}
	return self;

}

- (id)initWithRegion:(MKCoordinateRegion)region andPinLocation:(CLLocationCoordinate2D)coordinate fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil {

	if ((self = [self initWithRegion:region fromNibName:nibNameOrNil fromBundle:nibBundleOrNil])) {
		_location = coordinate;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	if (_region.center.latitude != 0 && _region.center.longitude != 0 && _region.span.latitudeDelta != 0 && _region.span.longitudeDelta != 0) {
		[mapView setRegion:_region animated:NO];
	}
	if (_location.latitude != 0 && _location.longitude != 0) {
		LocationPin *pin = [[LocationPin alloc] initWithCoordinate:_location];
		[mapView addAnnotation:pin];
		[pin release];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[mapView release]; mapView = nil;
    [super dealloc];
}


@end
