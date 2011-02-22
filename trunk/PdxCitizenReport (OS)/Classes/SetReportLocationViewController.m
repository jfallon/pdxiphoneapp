//
//  SetReportLocationViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/4/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "SetReportLocationViewController.h"
#import "DataRepository.h"
#import "LocationController.h"
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
		buttonImage = [UIImage imageNamed:@"iconMap.png"];
		toggleMapStyleButton.image = buttonImage;
		mapIsDisplayingAerialPhotos = YES;
		mapViewControl.mapType = MKMapTypeHybrid;
		targetImageView.image = [UIImage imageNamed:@"cross-hairs-small-yellow-cropped.png"];
	} else {
		buttonImage = [UIImage imageNamed:@"iconAirplane.png"];
		toggleMapStyleButton.image = buttonImage;
		mapIsDisplayingAerialPhotos = NO;
		mapViewControl.mapType = MKMapTypeStandard;
		targetImageView.image = [UIImage imageNamed:@"cross-hairs-small-black-cropped.png"];
	}
}

- (IBAction)toggleShowGpsLocationButtonPressed:(id)sender {
	
	if (LocationController.sharedInstance.locationServicesAvailable == NO) {
		return;
	}
	
	if (mapViewControl.showsUserLocation == NO) {
		mapViewControl.showsUserLocation = YES;
		toggleUserLocationButton.style = UIBarButtonItemStyleDone;
		[self zoomToGpsLocation:YES];
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
		globalData.unsentReport.latitude = savedLocation.coordinate.latitude;
		globalData.unsentReport.longitude = savedLocation.coordinate.longitude;
		[savedLocation release];
		[self dismissModalViewControllerAnimated:YES];	
		
		if (self.delegate != nil) {
			if ([self.delegate respondsToSelector:@selector(setReportLocationViewControllerDidSaveLocation:)]) {
				[delegate setReportLocationViewControllerDidSaveLocation:self];
			}
		}
		
	} else {
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Location"
															message:[NSString stringWithFormat:@"Report locations must be within the %@.", DataRepository.sharedInstance.agencyName] 
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
	
    if (LocationController.sharedInstance.locationServicesAvailable == NO) {
		[self zoomToRegion:animated];
		return;
	}
	
	if (mapViewControl.showsUserLocation == NO || mapViewControl.userLocation == nil) {
		[self zoomToRegion:animated];
		return;
	}
	@try {
		MKCoordinateRegion region;
		region.center.latitude = mapViewControl.userLocation.coordinate.latitude;
		region.center.longitude = mapViewControl.userLocation.coordinate.longitude;
		MKCoordinateSpan span;
		span.latitudeDelta = 0.0025; // arbitrary value seems to look OK
		span.longitudeDelta = 0.0025; // arbitrary value seems to look OK
		region.span = span;
		[mapViewControl setRegion:region animated:animated];
	}
	@catch (NSException * e) {
		[self zoomToRegion:animated];
	}
	@finally {
		
	}
}

- (void)zoomToProposedLocation:(bool)animated {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.proposedLocation == nil) {
		[self zoomToRegion:animated];
		return;
	}
	
	@try {
		MKCoordinateRegion region;
		region.center.latitude = globalData.proposedLocation.coordinate.latitude;
		region.center.longitude = globalData.proposedLocation.coordinate.longitude;
		MKCoordinateSpan span;
		span.latitudeDelta = 0.0025; // arbitrary value seems to look OK
		span.longitudeDelta = 0.0025; // arbitrary value seems to look OK
		region.span = span;
		[mapViewControl setRegion:region animated:animated];	
	}
	@catch (NSException * e) {
		[self zoomToRegion:animated];
	}
	@finally {
		
	}
}

- (void)zoomToRegion:(bool)animated {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	MKCoordinateRegion region;
	region.center.latitude = globalData.latitudeCenter;
	region.center.longitude = globalData.longitudeCenter;
	MKCoordinateSpan span;
	span.latitudeDelta = (globalData.latitudeNorth - globalData.latitudeSouth); 
	// trying to account for difference in the aspect ratio of the regions envelope and the iPhone's screen
	span.longitudeDelta = ((globalData.longitudeWest - globalData.longitudeEast) * -1);
	region.span = span;
	[mapViewControl setRegion:region animated:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	[super viewDidLoad];
	[mapViewControl setDelegate:self];
	[[navBar topItem] setTitle:@"Set Location"];
		
	// set UI based on if location services are available
	if (LocationController.sharedInstance.locationServicesAvailable == NO) {
		self.toggleUserLocationButton.style = UIBarButtonItemStyleBordered;
		self.toggleUserLocationButton.enabled = NO;
		self.mapViewControl.showsUserLocation = NO;
	}
	else {
		self.toggleUserLocationButton.style = UIBarButtonItemStyleDone;
		self.toggleUserLocationButton.enabled = YES;
		self.mapViewControl.showsUserLocation = YES;	
	}
	
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
		[self zoomToGpsLocation:YES];
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
