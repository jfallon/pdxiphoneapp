//
//  SetReportLocationViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/4/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SetReportLocationViewController;
@class ReportMapAnnotation;

@protocol SetReportLocationViewControllerDelegate <NSObject>
- (void)setReportLocationViewControllerDidCancel:(SetReportLocationViewController *)controller;
- (void)setReportLocationViewControllerDidSaveLocation:(SetReportLocationViewController *)controller;
@end

@interface SetReportLocationViewController : UIViewController <MKMapViewDelegate, UIAlertViewDelegate> {
																   
	IBOutlet MKMapView *mapViewControl;
	IBOutlet UINavigationBar *navBar;
	IBOutlet UIBarButtonItem *toggleMapStyleButton;
	IBOutlet UIBarButtonItem *toggleUserLocationButton;
	IBOutlet UIImageView *targetImageView;
	
	bool mapIsDisplayingAerialPhotos;
	CLLocationCoordinate2D undoLocation;
	id<SetReportLocationViewControllerDelegate> delegate;
}

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)toggleShowGpsLocationButtonPressed:(id)sender;
- (IBAction)toggleMapStyleButtonPressed:(id)sender;

- (void)zoomToGpsLocation:(bool)animated;
- (void)zoomToProposedLocation:(bool)animated;
- (void)zoomToRegion:(bool)animated;

@property(nonatomic,retain) IBOutlet MKMapView *mapViewControl;
@property(nonatomic,retain) IBOutlet UINavigationBar *navBar;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *toggleMapStyleButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *toggleUserLocationButton;
@property(nonatomic,retain) IBOutlet UIImageView *targetImageView;

@property(assign)id<SetReportLocationViewControllerDelegate> delegate;

// required by UIAlertViewDelegate protocol
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
