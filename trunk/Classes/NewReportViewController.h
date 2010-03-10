//
//  NewReportViewController.h
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
#import "SetReportLocationViewController.h"
#import "ReportCommentsViewController.h"

@class AppBusyViewController;
@class AppProgressViewController;
@class ASIHTTPRequest;
@class AppLongTextViewController;
@class ReportCommentsViewController;

@interface NewReportViewController : UIViewController <UINavigationControllerDelegate, 
													   UIActionSheetDelegate, 
													   UIImagePickerControllerDelegate, 
													   UITextViewDelegate,
													   UIPickerViewDelegate,
													   UIPickerViewDataSource,
													   UIAlertViewDelegate,
													   SetReportLocationViewControllerDelegate,
													   ReportCommentsViewControllerDelegate> {
	
IBOutlet UIImageView				*imageView;
IBOutlet UITextView					*reportCommentsTextView;
IBOutlet UILabel					*chooseReportTypeButtonLabel;
IBOutlet UILabel					*setReportLocationButtonLabel;
IBOutlet UIActivityIndicatorView	*commentsActivityView;

CGFloat					animatedDistance;
NSInteger				reportTypeIndex;
NSInteger				locationTimerFiredCount;
NSInteger				locationTimerMaximumCount;
NSInteger				sendReportBackgroundRetryCount;
bool					reportTypesLoaded;
bool					unsentReportLoaded;
bool					disclaimerHasBeenDisplayedOnce;
bool					contactInfoNagHasBeenDisplayedOnce;
	
UIActionSheet			*currentActionSheet;
UIPickerView			*reportTypePickerView;
NSTimer					*getLocationTimer; 
														   
AppBusyViewController			*busyViewController;														   
AppProgressViewController		*progressViewController;
AppLongTextViewController		*longTextViewController;
SetReportLocationViewController *reportLocationViewController;
ReportCommentsViewController	*reportCommentsViewController;
	
}

@property (nonatomic,retain) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) IBOutlet UITextView *reportCommentsTextView;
@property (nonatomic,retain) IBOutlet UILabel *chooseReportTypeButtonLabel;
@property (nonatomic,retain) IBOutlet UILabel *setReportLocationButtonLabel;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *commentsActivityView;

@property (nonatomic,retain) UIActionSheet *currentActionSheet;
@property (nonatomic,retain) UIPickerView *reportTypePickerView;
@property (nonatomic,retain) AppBusyViewController *busyViewController;
@property (nonatomic,retain) AppProgressViewController *progressViewController;
@property (nonatomic,retain) AppLongTextViewController *longTextViewController;
@property (nonatomic,retain) ReportCommentsViewController *reportCommentsViewController;
@property (nonatomic,retain) SetReportLocationViewController *reportLocationViewController;
@property (nonatomic,retain) NSTimer *getLocationTimer;

- (IBAction)showHowGetImageActionSheetFromButtonClick:(id)sender; 
- (IBAction)showReportTypePickerFromButtonClick:(id)sender;
- (IBAction)showHowSetReportLocationActionSheetFromButtonClick:(id)sender;
- (IBAction)submitReportFromButtonClick:(id)sender;
- (IBAction)cancelReportFromButtonClick:(id)sender;

// UIActionSheetDelegate protocol 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

// UIAlertViewDelegate protocol
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// UIImagePickerControllerDelegate protocol
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

// UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;

// UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

// UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (void)showEditUserCommentsView;

// SetReportLocationViewControllerDelegate
- (void)setReportLocationViewControllerDidCancel:(SetReportLocationViewController *)controller;
- (void)setReportLocationViewControllerDidSaveLocation:(SetReportLocationViewController *)controller;

// ReportCommentsViewControllerDelegate
- (void)reportCommentsViewControllerDidResign:(ReportCommentsViewController *)controller;

- (void)showAcquirePictureUI:(bool)existingPhotoFromRoll;
- (void)setUIButtonTitle:(UIButton *)button newTitle:(NSString *)buttonTitle;
- (void)reportTypeActionSheetSaveButtonClick;
- (void)reportTypeActionSheetCancelButtonClick;
- (void)clearNewReportView;

- (void)startGPSLocationAcquireLoop:(NSInteger)maximumNumberOfSamples sampleIntervalInSeconds:(NSInteger)intervalInSeconds; 
- (void)stopGPSLocationAcquireTimerLoop;
- (CLLocation *)getGPSLocation;
- (bool)isGPSLocationAccurateEnough:(CLLocation *)location;
- (void)getGPSLocationTimerFired;

- (void)sendReportToTrackIT;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (bool)parseReportSentXml:(NSString *)xmlData;
- (bool)cityWebServerIsReachable;

@end
