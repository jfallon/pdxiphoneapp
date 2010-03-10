//
//  SetReportLocationViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "SetReportLocationViewController.h"
#import "DataRepository.h"
#import "Report.h"
#import "ReportMapAnnotation.h"
#import "ReportMapAnnotationView.h"

@implementation SetReportLocationViewController

@synthesize mapViewControl;
@synthesize navBar;
@synthesize toggleUserLocationButton;
@synthesize toggleMapStyleButton;
@synthesize targetImageView;
@synthesize delegate;

- (void)dealloc {
	[mapViewControl release]; mapViewControl = nil;
	[toggleMapStyleButton release]; toggleMapStyleButton = nil;
	[toggleUserLocationButton release]; toggleUserLocationButton = nil;
	[targetImageView release]; targetImageView = nil;
	[navBar release]; navBar = nil;
    [super dealloc];
}

- (IBAction)toggleMapStyleButtonPressed:(id)sender {

	UIImage *buttonImage = nil;
	if (mapIsDisplayingAerialPhotos == NO) {
		buttonImage = [UIImage imageNamed:@"map.png"];
		toggleMapStyleButton.image = buttonImage;
		mapIsDisplayingAerialPhotos = YES;
		mapViewControl.mapType = MKMapTypeHybrid;
		targetImageView.image = [UIImage imageNamed:@"cross-hairs-small-yellow-cropped.png"];
	} else {
		buttonImage = [UIImage imageNamed:@"airplane.png"];
		toggleMapStyleButton.image = buttonImage;
		mapIsDisplayingAerialPhotos = NO;
		mapViewControl.mapType = MKMapTypeStandard;
		targetImageView.image = [UIImage imageNamed:@"cross-hairs-small-black-cropped.png"];
	}
}

- (IBAction)toggleShowGpsLocationButtonPressed:(id)sender {
	
	if (mapViewControl.showsUserLocation == NO) {
		mapViewControl.showsUserLocation = YES;
		toggleUserLocationButton.style = UIBarButtonItemStyleDone;
	}
	else {
		mapViewControl.showsUserLocation = NO;
		toggleUserLocationButton.style = UIBarButtonItemStyleBordered;
	}
}

- (IBAction)cancelButtonPressed:(id)sender {
	
	[self dismissModalViewControllerAnimated:YES];
	mapViewControl.centerCoordinate = undoLocation;
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(setReportLocationViewControllerDidCancel:)]) {
			[delegate setReportLocationViewControllerDidCancel:self];
		}
	}
}

- (IBAction)saveButtonPressed:(id)sender {

	CLLocationCoordinate2D centerCoord = [mapViewControl centerCoordinate];
	CLLocation *savedLocation = [[CLLocation alloc] initWithLatitude:centerCoord.latitude longitude:centerCoord.longitude];
	
    if ([[DataRepository sharedInstance] locationIsInCity:savedLocation] == YES) {
		DataRepository *globalData = [DataRepository sharedInstance];
		globalData.proposedLocation = savedLocation;
		if (globalData.unsentReport != nil) {
			globalData.unsentReport.latitude = savedLocation.coordinate.latitude;
			globalData.unsentReport.longitude = savedLocation.coordinate.longitude;
		}
		[savedLocation release];
		[self dismissModalViewControllerAnimated:YES];	
		
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(setReportLocationViewControllerDidSaveLocation:)]) {
				[delegate setReportLocationViewControllerDidSaveLocation:self];
			}
		}
		
	} else {
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Location"
															message:@"Report locations must be within the City of Portland." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:0];
		[alertView show];	
		[alertView release];
		[savedLocation release];
		return;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// user selected a bogus location
	if ([alertView tag] == 0) {
		// nothing to do currently
	}
}


- (void)zoomToGpsLocation:(bool)animated {
	
	if (mapViewControl.showsUserLocation == NO || mapViewControl.userLocation == nil) {
		return;
	}
	if (mapViewControl.userLocationVisible == YES) {
		return;
	}
	
	[mapViewControl setCenterCoordinate:mapViewControl.userLocation.coordinate animated:YES];
}



- (void)zoomToProposedLocation:(bool)animated {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.proposedLocation == nil) {
		[self zoomToRegion:animated];
		return;
	}
	MKCoordinateRegion region;
	region.center.latitude = globalData.proposedLocation.coordinate.latitude;
	region.center.longitude = globalData.proposedLocation.coordinate.longitude;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0025; // arbitrary value seems to look OK
	span.longitudeDelta = 0.0025; // arbitrary value seems to look OK
	region.span = span;
	[mapViewControl setRegion:region animated:animated];	
}
- (void)zoomToRegion:(bool)animated {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	MKCoordinateRegion region;
	region.center.latitude = globalData.latitudeCenter;
	region.center.longitude = globalData.longitudeCenter;
	MKCoordinateSpan span;
	span.latitudeDelta = (globalData.latitudeNorth - globalData.latitudeSouth); 
	//trying to account for difference in the aspect ratio of the regions envelope and the iPhone's screen
	span.longitudeDelta = ((globalData.longitudeWest - globalData.longitudeEast) * -1);
	region.span = span;
	[mapViewControl setRegion:region animated:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	[mapViewControl setDelegate:self];
	[[navBar topItem] setTitle:@"Set Location"];
	
	// determine if we have a proposed location and if that location is roughly within the city of portland
	DataRepository *globalData = [DataRepository sharedInstance];
	bool useProposedLocation = NO;
	if (globalData.proposedLocation == nil) {
		useProposedLocation = NO;
	}
	else {
		if ([globalData locationIsInCity:globalData.proposedLocation]) {
			useProposedLocation = YES;
		}
		else {
			useProposedLocation = NO;
		}
	}
	if (useProposedLocation == YES) {
		[self zoomToProposedLocation:YES];
	} else {
		[self zoomToRegion:YES];
	}
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.proposedLocation == nil) {
		undoLocation.latitude = mapViewControl.centerCoordinate.latitude;
		undoLocation.longitude = mapViewControl.centerCoordinate.longitude;
	}
	else {
		undoLocation.latitude = globalData.proposedLocation.coordinate.latitude;
		undoLocation.longitude = globalData.proposedLocation.coordinate.longitude;
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

@end
