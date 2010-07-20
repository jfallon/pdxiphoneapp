//
//  ReportStatusDetailViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "ReportStatusDetailViewController.h"
#import "ReportDetailWebViewController.h"
#import "DataRepository.h"
#import "DisplayLocationViewController.h"
#import "DisplayImageViewController.h"
#import "Report.h"

@implementation ReportStatusDetailViewController

@synthesize detailURL;
@synthesize webViewControl;
@synthesize activityView;

- (void)dealloc {
	[detailURL release]; detailURL = nil;
	[webViewControl release]; webViewControl = nil;
	[activityView release]; activityView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	pageLoaded = NO;
	DataRepository *globalData = [DataRepository sharedInstance];
	if ([globalData internetIsReachableRightNow] == YES && globalData.connectionRequiredForInternet == NO) {
		if (globalData.getItemDetailUrlSuffix.length > 0 && globalData.getItemDetailUrlParameters.length > 0) {
			self.detailURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",globalData.urlPrefix,globalData.getItemDetailUrlSuffix,globalData.getItemDetailUrlParameters]];
			NSURLRequest *request = [NSURLRequest requestWithURL:self.detailURL];
			[self.webViewControl loadRequest:request];
			pageLoaded = YES;
		}
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[self activityView] startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[self activityView] stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
 
	NSString *thisRequestString = [[[request URL] absoluteString] lowercaseString] ;
	if ([thisRequestString isEqualToString:[[[self detailURL] absoluteString] lowercaseString]]) {
		return YES;
	}
	else {
		DataRepository *globalData = [DataRepository sharedInstance];
		if ([globalData stringContains:thisRequestString subString:globalData.getItemMapUrlSuffix]==YES) {
			DisplayLocationViewController *controller = nil;		
			MKCoordinateRegion region;
			if (globalData.selectedReport != nil && globalData.selectedReport.latitude != 0 && globalData.selectedReport.longitude != 0) {
				Report *report = globalData.selectedReport;
				// set location of report pin and center of map
				CLLocationCoordinate2D reportLocation;
				reportLocation.latitude = report.latitude;
				reportLocation.longitude = report.longitude;
				// set map region
				region.center = reportLocation;
				MKCoordinateSpan span;
				span.latitudeDelta = 0.0012; // arbitrary value seems to look OK
				span.longitudeDelta = 0.0012; // arbitrary value seems to look OK
				region.span = span;
				controller = [[DisplayLocationViewController alloc] initWithRegion:region andPinLocation:reportLocation fromNibName:@"DisplayLocationView" fromBundle:nil];
				[controller setTitle:@"Location"];
			}
			else {
				region.center.latitude = globalData.latitudeCenter;
				region.center.longitude = globalData.longitudeCenter;
				MKCoordinateSpan span;
				span.latitudeDelta = (globalData.latitudeNorth - globalData.latitudeSouth); 
				span.longitudeDelta = ((globalData.longitudeWest - globalData.longitudeEast) * -1);
				region.span = span;
				controller = [[DisplayLocationViewController alloc] initWithRegion:region fromNibName:@"DisplayLocationView" fromBundle:nil];
				[controller setTitle:@"Unknown Location"];
			}
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
			return NO;
		}
		
		if ([globalData stringContains:thisRequestString subString:globalData.getItemPhotoUrlSuffix]==YES) {
			NSString *address = [NSString stringWithFormat:@"%@%@?input_value_id=%ld&item_id=%ld&device_id=%@",DataRepository.sharedInstance.urlPrefix, DataRepository.sharedInstance.getItemPhotoUrlSuffix, (long)globalData.selectedReport.imageID, (long)globalData.selectedReport.number, globalData.deviceID];
			NSURL *url = [NSURL URLWithString:address];
			DisplayImageViewController *controller = [[DisplayImageViewController alloc] initWithURL:url fromNibName:@"DisplayImageView" fromBundle:nil];
			[controller setTitle:@"Photo"];
			[self.navigationController pushViewController:controller animated:YES];
			[controller release];
			return NO;
		}
		return NO;
	}
}






@end
