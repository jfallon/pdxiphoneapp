//
//  NewReportViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "NewReportViewController.h"
#import "LocationController.h"
#import "AppBusyViewController.h"
#import "AppProgressViewController.h"
#import "Report.h"
#import "TrackItInstance.h"
#import "DataRepository.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DDXML.h"
#import "AppSettings.h"
#import "UIImage+Resize.h"
#import "AppLongTextViewController.h"
#import "ReportCommentsViewController.h"

@implementation NewReportViewController

@synthesize imageView;
@synthesize reportCommentsTextView;
@synthesize currentActionSheet;
@synthesize chooseReportTypeButtonLabel;
@synthesize setReportLocationButtonLabel;
@synthesize commentsActivityView;

@synthesize reportTypePickerView;
@synthesize busyViewController;
@synthesize progressViewController;
@synthesize getLocationTimer;
@synthesize longTextViewController;
@synthesize reportLocationViewController;
@synthesize reportCommentsViewController;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

#pragma mark UIViewController method overloads 

- (void)dealloc {
	[commentsActivityView release]; commentsActivityView = nil;
	[imageView release]; imageView = nil;
	[reportCommentsTextView release]; reportCommentsTextView = nil;
	[currentActionSheet release]; currentActionSheet = nil;
	[chooseReportTypeButtonLabel release]; chooseReportTypeButtonLabel = nil;
	[setReportLocationButtonLabel release]; setReportLocationButtonLabel = nil;
	[reportTypePickerView release]; reportTypePickerView = nil;
	[busyViewController release]; busyViewController = nil;
	[progressViewController release]; progressViewController = nil;
	[getLocationTimer release]; getLocationTimer = nil;
	[longTextViewController release]; longTextViewController = nil;
	[reportLocationViewController release]; reportLocationViewController = nil;
	[reportCommentsViewController release]; reportCommentsViewController = nil;
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	reportTypeIndex = -1;
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	
	// conditionally populate UI with a previous report
	if (unsentReportLoaded == NO) {
		unsentReportLoaded = YES;
		Report *unsentReport = [[DataRepository sharedInstance] unsentReport];
		if (unsentReport != nil) {
			if (unsentReport.image != nil) {
				imageView.alpha = 1.0;
				imageView.image = unsentReport.image;
			}
			if (unsentReport.comments.length > 0) {
				self.reportCommentsTextView.text = unsentReport.comments;
			}
			if (unsentReport.reportType.length > 0) {
				NSString *buttonTitle = [@"Report Type: " stringByAppendingString:unsentReport.reportType];
				[[self chooseReportTypeButtonLabel] setText:buttonTitle];
			}
			if ([unsentReport latitude] !=0 && [unsentReport longitude] !=0) {
				CLLocation  *proposedLocation = [[CLLocation alloc] initWithLatitude:[unsentReport latitude] longitude:[unsentReport longitude]];
				[[DataRepository sharedInstance] setProposedLocation:proposedLocation];
				[proposedLocation release];
				[[self setReportLocationButtonLabel] setText:@"Change Report Location"];				
			}
		}
	}
	
	AppSettings *settings = DataRepository.sharedInstance.appSettings;
	if (disclaimerHasBeenDisplayedOnce == NO) {
		if ((settings.usageWarningInterval != 0) && (settings.usageWarningCounter == 1)) {
			if (settings.usageWarningText.length == 0) {
				settings.usageWarningText = @"Some Disclaimer Text Goes Here"
			}
			if (self.longTextViewController == nil) {
				self.longTextViewController = [[AppLongTextViewController alloc] initWithNibName:@"AppLongTextView" bundle:nil];
			}
			[[[[[self view] superview] superview] superview] addSubview:self.longTextViewController.view];
			disclaimerHasBeenDisplayedOnce = YES;
			UITextView *textView = self.longTextViewController.textView;
			[textView setText:nil];
			[textView setText:settings.usageWarningText];
			[textView setEditable:NO];
			[textView setDataDetectorTypes:UIDataDetectorTypeAll];
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[busyViewController release]; busyViewController = nil;
	[progressViewController release]; progressViewController = nil;
	[longTextViewController release]; longTextViewController = nil;
	[reportCommentsViewController release]; reportCommentsViewController = nil;
	[reportLocationViewController release]; reportLocationViewController = nil;
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Get Photo Button Action

// called when UIControlEventTouchUpInside event fires on 'Report an Issue' button
- (IBAction)showHowGetImageActionSheetFromButtonClick:(id)sender {
	
	[currentActionSheet release]; currentActionSheet = nil;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
		currentActionSheet = [[UIActionSheet alloc]
							  initWithTitle:nil
							  delegate:self
							  cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:nil
							  otherButtonTitles:@"Take New Photo", @"Choose From Library", @"No Photo",nil];
		currentActionSheet.tag = 0;
	}
	else {
		currentActionSheet = [[UIActionSheet alloc]
							  initWithTitle:nil
							  delegate:self
							  cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:nil
							  otherButtonTitles:@"Choose From Library", @"No Photo",nil];
		currentActionSheet.tag = 4;
	}

	currentActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[currentActionSheet showInView:self.tabBarController.view];
}

#pragma mark Set Report Location Button Action 

- (IBAction)showHowSetReportLocationActionSheetFromButtonClick:(id)sender {
	
	[currentActionSheet release]; currentActionSheet = nil;
	
	if (LocationController.sharedInstance.locationServicesAvailable == YES ) {
		currentActionSheet = [[UIActionSheet alloc]
							  initWithTitle:nil
							  delegate:self
							  cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:nil
							  otherButtonTitles:@"Use GPS Location", @"Select Location On Map",nil];
		currentActionSheet.tag = 2;
	}
	else {
		currentActionSheet = [[UIActionSheet alloc]
							  initWithTitle:nil
							  delegate:self
							  cancelButtonTitle:@"Cancel"
							  destructiveButtonTitle:nil
							  otherButtonTitles:@"Select Location On Map",nil];
		currentActionSheet.tag = 3;
	}
	currentActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[currentActionSheet showInView:self.tabBarController.view];
}

#pragma mark Set Location View Controller callbacks

// callback from set report location view indicating how user left that screen
- (void)setReportLocationViewControllerDidCancel:(SetReportLocationViewController *)controller {
	// currently no action needs to be taken
}

// callback from set report location view indicating how user left that screen
- (void)setReportLocationViewControllerDidSaveLocation:(SetReportLocationViewController *)controller {
	[[self setReportLocationButtonLabel] setText:@"Change Report Location"];	
}


#pragma mark UIActionSheet callback

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// action sheet used to choose photo (camera or library) source on devices with cameras
	if (actionSheet.tag == 0) {
		if (buttonIndex == 3) {
			// user clicked cancel
			return;
		}
		if (buttonIndex == 0) {
			[self showAcquirePictureUI:NO];
		}
		else if (buttonIndex == 1) {
			[self showAcquirePictureUI:YES];		
		}
		else {
			// clear the image
			imageView.alpha = 0.0;
			[imageView setImage:nil];
			[[[DataRepository sharedInstance] unsentReport] setImage:nil];
		}
	}
	
	// action sheet used to choose photo (library) source on devices without cameras
	if (actionSheet.tag == 4) {
		if (buttonIndex == 2) {
			// user clicked cancel
			return;
		}
		if (buttonIndex == 0) {
			[self showAcquirePictureUI:YES];
		}
		else {
			// clear the image
			imageView.alpha = 0.0;
			[imageView setImage:nil];
			[[[DataRepository sharedInstance] unsentReport] setImage:nil];
		}
	}
	
	// action sheet that pickerview is on, nothing to do here right now, it's the selector
	// called by the two toolbar buttons that are also on this actionsheeet that dismiss it
	if (actionSheet.tag == 1) {}
	
	// action shet used to choose location (gps or map) source
	if (actionSheet.tag == 2) {
		
		if (buttonIndex == 2) {
			// user clicked cancel
			return;
		}
		if (LocationController.sharedInstance.locationServicesAvailable == YES) {
			if (buttonIndex == 0) {
				// use current location (GPS)
				CLLocation *currentLocation = [[self getGPSLocation] retain];
				[[DataRepository sharedInstance] setProposedLocation:currentLocation];
				Report *report = DataRepository.sharedInstance.unsentReport;
				if (report != nil) {
					report.latitude = DataRepository.sharedInstance.proposedLocation.coordinate.latitude;
					report.longitude = DataRepository.sharedInstance.proposedLocation.coordinate.longitude;
				}
				if ([self isGPSLocationAccurateEnough:currentLocation] == NO) {
					// location was not within our accuracy requirements, start 
					// a polling loop to see if we can get something better
					[self startGPSLocationAcquireLoop:DataRepository.sharedInstance.appSettings.gpsSampleCount 
							  sampleIntervalInSeconds:DataRepository.sharedInstance.appSettings.gpsSampleIntervalInSeconds];
				} 
				else {
					// location was good enough, cache the location and
					// update the UI to reflect that we have a good fix
				}
				[currentLocation release];
			} 
			else {
				// select location on map by bringing up view which contains map view
				if (self.reportLocationViewController == nil) {
					self.reportLocationViewController = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
				}
				self.reportLocationViewController.delegate = self;
				[self.tabBarController presentModalViewController:self.reportLocationViewController animated:YES];
			}
		}
		else {
			if (buttonIndex == 1) {
				// user clicked cancel
				return;
			}
			// select location on map by bringing up view which contains map view
			if (self.reportLocationViewController == nil) {
				self.reportLocationViewController = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
			}
			self.reportLocationViewController.delegate = self;
			[self.tabBarController presentModalViewController:self.reportLocationViewController animated:YES];
		}
	}
	
	if (actionSheet.tag == 3) {
		
		if (buttonIndex == 1) {
			return;
		}
		else {
			// select location on map by bringing up view which contains map view
			if (self.reportLocationViewController == nil) {
				self.reportLocationViewController = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
			}
			self.reportLocationViewController.delegate = self;
			[self.tabBarController presentModalViewController:self.reportLocationViewController animated:YES];
		}
	}
	
	if (currentActionSheet != nil) {
		[currentActionSheet release];
		currentActionSheet = nil;
	}
}


#pragma mark Choose Photo methods and Image Picker callbacks

- (void)showAcquirePictureUI:(bool)existingPhotoFromRoll {
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.allowsEditing = NO;
	if (existingPhotoFromRoll == YES) {
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	}
	else {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// user completed choosing or taking a picture
	[picker dismissModalViewControllerAnimated:YES];
	imageView.alpha = 1.0;
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	//resize the image that will be sent to city webservice
	CGFloat originalWidth = image.size.width;
	CGFloat originalHeight = image.size.height;
	CGFloat smallerDimensionMultiplier;
	CGFloat newWidth;
	CGFloat newHeight;
	if (originalWidth > originalHeight) {
		smallerDimensionMultiplier = originalHeight / originalWidth;
		newWidth = DataRepository.sharedInstance.appSettings.photoLargestSideInPixels;
		newHeight = newWidth * smallerDimensionMultiplier;
	}
	else {
		smallerDimensionMultiplier = originalWidth / originalHeight;
		newHeight =  DataRepository.sharedInstance.appSettings.photoLargestSideInPixels;
		newWidth = newHeight * smallerDimensionMultiplier;
	}
	CGSize newSize;
	newSize.width = newWidth;
	newSize.height = newHeight;
	UIImage *resizedImage = [image resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
	Report *report = [[[DataRepository sharedInstance] unsentReport] retain];
	report.image = resizedImage;
	[report release];
	imageView.image = resizedImage;
	return;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// user canceled out of picking an image
	[picker dismissModalViewControllerAnimated:YES];
	return;
}


#pragma mark Set Report Type methods and UIPickerView callbacks

- (IBAction)showReportTypePickerFromButtonClick:(id)sender {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	if (globalData.trackItInstanceArray.count == 0) {
		if (globalData.internetIsReachable == YES && globalData.connectionRequiredForInternet == NO) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Types Unavailable"
																message:@"The list of valid report types have not reached your device yet. Please press OK, wait a couple seconds, then try again." 
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:10];
			[alertView show];	
			[alertView release];
			return;
		}
		else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Types Unavailable"
																message:@"Unable to retrieve a list of valid report types, the internet is not currently reachable on this device. Please try again later." 
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:10];
			[alertView show];	
			[alertView release];
			return;
		}
	}
	
	if (currentActionSheet != nil) {
		[currentActionSheet release];
		currentActionSheet = nil;
	}
	currentActionSheet = [[UIActionSheet alloc] 
						  initWithTitle:@"Choose Report Type"
						  delegate:self 
						  cancelButtonTitle:nil 
						  destructiveButtonTitle:nil
						  otherButtonTitles:nil];
	
	reportTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	reportTypePickerView.delegate = self;
	reportTypePickerView.showsSelectionIndicator = YES;
	
	UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	pickerToolbar.barStyle = UIBarStyleBlack;
	[pickerToolbar sizeToFit];
	
	NSMutableArray *barItems = [[NSMutableArray alloc] init];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
								   target:self 
								   action:@selector(reportTypeActionSheetSaveButtonClick)];
	[barItems addObject:doneButton];
	[doneButton release];

	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
								  target:self 
								  action:nil];
	[barItems addObject:flexSpace];
	[flexSpace release];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
									 target:self 
									 action:@selector(reportTypeActionSheetCancelButtonClick)];
	[barItems addObject:cancelButton];
	[cancelButton release];
	[pickerToolbar setItems:barItems animated:NO];
	[barItems release];

	[currentActionSheet addSubview:pickerToolbar];
	[pickerToolbar release];
	
	[currentActionSheet addSubview:reportTypePickerView];

	[currentActionSheet showInView:self.view];
	[currentActionSheet setBounds:CGRectMake(0.0, 0.0, 320.0, 464.0)];
	if (reportTypeIndex != -1 && reportTypeIndex <= [[[DataRepository sharedInstance]trackItInstanceArray]count]) {
		[reportTypePickerView selectRow:reportTypeIndex inComponent:0 animated:NO];
	}
}

- (void)reportTypeActionSheetSaveButtonClick {
	
	if (currentActionSheet != nil) {
		reportTypeIndex = [reportTypePickerView selectedRowInComponent:0];
		NSString *reportType = nil;
		NSString *buttonTitle = nil;
		TrackItInstance *instance = nil;
		if (reportTypesLoaded == YES) {
			instance = [[[DataRepository sharedInstance] trackItInstanceArray] objectAtIndex:reportTypeIndex];
			reportType = [NSString stringWithString:[instance instanceName]];
			buttonTitle = [@"Report Type: " stringByAppendingString:reportType];
			[[[DataRepository sharedInstance] unsentReport] setReportType:reportType];
			[[self chooseReportTypeButtonLabel] setText:buttonTitle];
		}
		
	    [currentActionSheet dismissWithClickedButtonIndex:0 animated:YES];
		[reportTypePickerView release]; reportTypePickerView = nil;
		[currentActionSheet release]; currentActionSheet = nil;

		if ((instance != nil) && (instance.instanceMessage.length > 0)) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:instance.instanceMessage
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:11];
			[alertView show];	
			[alertView release];
			return;							  
		}
	}
}

- (void)reportTypeActionSheetCancelButtonClick {
	if (currentActionSheet != nil) {
		[currentActionSheet dismissWithClickedButtonIndex:0 animated:YES];
		if (reportTypePickerView != nil) {
			[reportTypePickerView release];
			reportTypePickerView = nil;
		}
		if (currentActionSheet != nil) {
			[currentActionSheet release];
			currentActionSheet = nil;
		}
	}
}

- (void)setUIButtonTitle:(UIButton *)button newTitle:(NSString *)buttonTitle {
	if (button == nil || buttonTitle == nil) {
		return;
	}
	[button setTitle:buttonTitle forState:UIControlStateNormal];
	[button setTitle:buttonTitle forState:UIControlStateDisabled];
	[button setTitle:buttonTitle forState:UIControlStateHighlighted];
	[button setTitle:buttonTitle forState:UIControlStateSelected];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (reportTypesLoaded == YES) {
		TrackItInstance *instance = [[[DataRepository sharedInstance] trackItInstanceArray] objectAtIndex:row];
		return instance.instanceName;
	}
	else {
		return nil; //[[DataRepository sharedInstance] genericReportType];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	if (component == 0) {
		NSMutableArray *instanceArray = [[DataRepository sharedInstance] trackItInstanceArray];
		if (instanceArray == nil || instanceArray.count == 0)
		{
			reportTypesLoaded = NO;
			return 1;
		}
		else {
			reportTypesLoaded = YES;
			return instanceArray.count;
		}
	}
	else {
		return 0;
	}
}

#pragma mark User Comments methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	[commentsActivityView startAnimating];
	[self performSelector:@selector(showEditUserCommentsView) withObject:nil afterDelay:0.01];
	return NO;
}

- (void)reportCommentsViewControllerDidResign:(ReportCommentsViewController *)controller {
	[commentsActivityView stopAnimating];
	self.reportCommentsTextView.text = [[[DataRepository sharedInstance]unsentReport]comments];
	self.reportCommentsViewController.delegate = nil;
}

- (void)showEditUserCommentsView {
	if (self.reportCommentsViewController == nil) {
		self.reportCommentsViewController = [[ReportCommentsViewController alloc] initWithNibName:@"ReportCommentsView" bundle:nil];
	}
	[self.tabBarController presentModalViewController:self.reportCommentsViewController animated:YES];
	self.reportCommentsViewController.delegate = self;
	[[[self reportCommentsViewController] commentsTextView] becomeFirstResponder];
}

#pragma mark Submit Button action and supporting methods


- (IBAction)submitReportFromButtonClick:(id)sender {
	
	// get the instance object 
	DataRepository *globalData = [DataRepository sharedInstance];
	TrackItInstance *instance = nil;
	if (reportTypeIndex == -1) {
		NSMutableArray *trackItInstanceArray = globalData.trackItInstanceArray;
		if (trackItInstanceArray.count > 0) {
			int i, count = [trackItInstanceArray count];
			for (i = 0; i < count; i++) {
				instance = [trackItInstanceArray objectAtIndex:i];
				NSString *instanceName = instance.instanceName;
				NSString *reportType = globalData.unsentReport.reportType;
				if ([instanceName isEqualToString:reportType]) {
					reportTypeIndex = i;
					break;
				}
			}
		}
	}
	if (reportTypeIndex >= 0  && (reportTypeIndex <= (globalData.trackItInstanceArray.count - 1))) {
		instance = [[globalData trackItInstanceArray] objectAtIndex:reportTypeIndex];
	}
	else {
		instance = nil;
	}
	
	if (globalData.deviceIsBlackListed == YES) {
		NSString *blackListMessage = nil;
		if ([[[globalData blackListReason] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0) {
			blackListMessage = [NSString stringWithFormat:@"This device has been blocked from submitting reports, the following reason was recorded: '%@'. If you feel this is in error, please contact <some responsible party> for assistance.", DataRepository.sharedInstance.blackListReason];
		}
		else {
			blackListMessage = @"This device has been blocked from submitting reports. If you feel this is in error, please contact <some responsible party> for assistance.";
		}
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Blocked Device"
															message:blackListMessage 
															delegate:self 
															cancelButtonTitle:@"OK" 
															otherButtonTitles:nil];
		[alertView setTag:4];
		[alertView show];	
		[alertView release];
		return;
	}
	
	// check we have sufficient data to submit a report
	NSString *incompleteReportMessage = nil;
	bool reportComplete = YES;
	
	if (reportTypeIndex == -1 && globalData.unsentReport.reportType.length == 0) {
		
		incompleteReportMessage = @"Every report must include a report type before it can be submitted.";
		reportComplete = NO;	
		
	}
	else {

		if (instance != nil) {
			
			NSString *messagePrefix = @"The current report requires the following before submittal:\n\n";	
			NSString *imageRequired = [NSString stringWithFormat:@"%@", (instance.imageRequired ? @"Photo\n" : @"")];
			NSString *addressRequired = [NSString stringWithFormat:@"%@", (instance.addressRequired ? @"Location\n" : @"")];
			NSString *commentsRequired = [NSString stringWithFormat:@"%@", (instance.commentsRequired ? @"Comments\n" : @"")];
			
			incompleteReportMessage = [NSString stringWithFormat:@"%@%@%@%@",messagePrefix,imageRequired,addressRequired,commentsRequired];
			if (instance.imageRequired == YES) {
				if (globalData.unsentReport.image == nil) {
					reportComplete = NO;
				}
			}
			if (instance.addressRequired == YES) {
				if (globalData.proposedLocation == nil) {
					reportComplete = NO;
				}
			}
			if (instance.commentsRequired == YES) {
				if (globalData.unsentReport.comments.length == 0) {
					reportComplete = NO;
				}
			}
		}
	}
	
	
	if (reportComplete == NO) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incomplete Report"
															message:incompleteReportMessage
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:8];
		[alertView show];	
		[alertView release];
		return;	
	}
	
	if ([globalData locationIsInCity:globalData.proposedLocation] == NO) {
		if (instance != nil && instance.addressRequired == YES) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Report Location"
																message:@"Unable to submit your report, the specified location is outside of the City of Portland." 
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:9];
			[alertView show];	
			[alertView release];
			return;
		}
	}
	
	AppSettings *settings = DataRepository.sharedInstance.appSettings;
	if (contactInfoNagHasBeenDisplayedOnce == NO) {
		if ((settings.usageWarningInterval != 0) && (settings.usageWarningCounter == 1)) {
			bool showNagScreen = NO;
			if (settings.userName.length == 0) {
				showNagScreen = YES;
			}
			else {
				if ((settings.userEmailAddress.length == 0) && (settings.userTelephoneNumber.length == 0)) {
					showNagScreen = YES;
				}
			}
			if (showNagScreen == YES) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Contact Info?"
																	message:@"Please consider filling out the contact information found on the 'Settings' tab of this app.  While contact information is optional, it helps us respond to reports more effectively. Would you like to fill out your contact information now?" 
																   delegate:self 
														  cancelButtonTitle:nil
														  otherButtonTitles:@"Yes", @"No", nil];
				[alertView setTag:12];
				[alertView show];	
				[alertView release];
				contactInfoNagHasBeenDisplayedOnce = YES;
				return;		
			}
		}
	}
	
	if ([[DataRepository sharedInstance] internetIsReachableRightNow] == NO || DataRepository.sharedInstance.connectionRequiredForInternet == YES) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
															message:@"Unable to submit report, your device is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:5];
		[alertView show];	
		[alertView release];
		return;
	}
		
	// finally submit the report
	sendReportBackgroundRetryCount = 0;
	[self sendReportToTrackIT];
	
}

- (void)sendReportToTrackIT {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	
	if (reportTypeIndex == -1 ) {
		NSMutableArray *trackItInstanceArray = globalData.trackItInstanceArray;
		if (trackItInstanceArray.count > 0) {
			int i, count = [trackItInstanceArray count];
			for (i = 0; i < count; i++) {
				TrackItInstance *instance = [trackItInstanceArray objectAtIndex:i];
				NSString *instanceName = instance.instanceName;
				NSString *reportType = globalData.unsentReport.reportType;
				if ([instanceName isEqualToString:reportType]) {
					reportTypeIndex = i;
					break;
				}
			}
		}
	}
	
	if (reportTypeIndex >= 0) {
		TrackItInstance *instance = [[globalData trackItInstanceArray] objectAtIndex:reportTypeIndex];
		if (instance != nil) {
			
			// show the HTTP post progress indicator
			//if (self.progressViewController == nil) {
			//	progressViewController = [[AppProgressViewController alloc] initWithNibName:@"AppProgressView" bundle:nil];
			//}
			//self.progressViewController.progressView.progress = 0;
			//[[[[[self view] superview] superview] superview] addSubview:self.progressViewController.view];
			//self.progressViewController.progressLabel.text = @"Please wait, currently uploading your report to the City of Portland...";
			
			if (self.busyViewController == nil) {
				AppBusyViewController *controller = [[AppBusyViewController alloc] initWithNibName:@"AppBusyView" bundle:nil];
				self.busyViewController = controller;
				[controller release];
				
				[[[[[self view] superview] superview] superview] addSubview:self.busyViewController.view];
				NSString *labelText = [NSString stringWithFormat:@"Please wait, currently uploading your report to <some organization>..."];
				[[self.busyViewController activityIndicatorLabel] setText:labelText];
				[self.busyViewController startProgressIndicator];
			}
			
			if ([self cityWebServerIsReachable]==NO) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable To Send Report"
																	message:@"The <some organization> webserver is not currently reachable from this device. Please try sending your report later." 
																   delegate:self 
														  cancelButtonTitle:@"OK" 
														  otherButtonTitles:nil];
				[alertView setTag:7];
				[alertView show];
				[alertView release];	
				return;	
			}
			
			// persist it before trying to send it over wire
			// NSString *fileName = [self determine
			
			NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] sendReportToTrackItUrlSuffix]];
			NSURL *url = [NSURL URLWithString:address];
			ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
			[request setPostValue:globalData.verifyValue forKey:@"verify"];
			[request setPostValue:globalData.deviceID forKey:@"device_id"];
			[request setPostValue:[NSString stringWithFormat:@"%ld",(long)instance.number] forKey:@"track_id"];
			[request setPostValue:[NSString stringWithFormat:@"%ld",(long)instance.category] forKey:@"category_id"];
			[request setPostValue:globalData.unsentReport.comments  forKey:instance.commentsInputName];
			[request setPostValue:globalData.unsentReport.streetAddress forKey:instance.addressStringInputName];			
			[request setPostValue:[NSString stringWithFormat:@"%f",globalData.unsentReport.longitude] forKey:instance.addressXInputName];
			[request setPostValue:[NSString stringWithFormat:@"%f",globalData.unsentReport.latitude] forKey:instance.addressYInputName];
			[request setUserInfo:[NSDictionary dictionaryWithObject:@"post_new_report" forKey:@"request_type"]];
			// add the image if one exists
			if (globalData.unsentReport.image != nil) {
				NSData *imageData = UIImageJPEGRepresentation(globalData.unsentReport.image, globalData.appSettings.jpegCompressionFactor);
				[request setData:imageData withFileName:@"report_photo.jpg" andContentType:@"image/jpeg" forKey:instance.imageInputName];
				[request setTimeOutSeconds:90];
			} else {
				[request setTimeOutSeconds:45];
			}
			[request setDelegate:self];
			//[request setUploadProgressDelegate:self.progressViewController.progressView];
			[request startAsynchronous];
		}
	}
	else {
		UIAlertView *alertView = [[UIAlertView alloc] 
								  initWithTitle:@"Send Report Failed"
								  message:@"The report type you originally selected for this unsent report is no longer available in Citizen Reports.  Please choose a different report type and submit again." 
								  delegate:self 
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[alertView setTag:6];
		[alertView show];
		[alertView release];
	}
}

// kinda scary running this synchronous, but seems quick and necessary for determining absolute server reachability as opposed to theoretical reachability
- (bool)cityWebServerIsReachable {
	
	NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] pingServerUrlSuffix]];
	NSURL *url = [NSURL URLWithString:address];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	NSError *error = [request error];
	if (!error) {
		NSString *response = [request responseString];
		if (request.responseStatusCode == 200 && [response isEqualToString:@"PING"]) {
			return YES;
		}
	}
	return NO;	
}

#pragma mark Cancel Button action and supporting methods

- (IBAction)cancelReportFromButtonClick:(id)sender{

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
											  message:@"Cancel submitting this report and clear the screen?" 
											  delegate:self 
										      cancelButtonTitle:nil 
										      otherButtonTitles:@"Yes", @"No", nil];
	[alertView setTag:0];
	[alertView show];
	[alertView release];
	return;
}

- (void)clearNewReportView {
	
	Report *newReport = [[Report alloc] init];
	[[DataRepository sharedInstance] setUnsentReport:newReport];
	[newReport release];
	[[DataRepository sharedInstance] setProposedLocation:nil];
	self.imageView.alpha = 0.0;
	[self.imageView setImage:nil];
	reportTypeIndex = -1;
	[self.reportCommentsTextView setText:@"Add comments here..."];
	[[self chooseReportTypeButtonLabel] setText:@"Choose Report Type"];
	[[self setReportLocationButtonLabel] setText:@"Set Report Location"];
	if (self.reportLocationViewController != nil) {
		[reportLocationViewController zoomToRegion:NO];
	}
}


#pragma mark UIAlertView callback

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// alert for canceling the report and clearing new report view
	if ([alertView tag] == 0) {
		if (buttonIndex == 0) {
			[self clearNewReportView];
		}
		return;
	}

	// alert for GPS location being inaccurate and user needs to manually locate on map
	if ([alertView tag] == 1) {
		DataRepository *globalData = [DataRepository sharedInstance];
		if (self.reportLocationViewController == nil) {
			self.reportLocationViewController = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
		}
		if ([globalData locationIsInCity:globalData.proposedLocation] == YES) {
			[[self reportLocationViewController] zoomToProposedLocation:NO];
		}	
		else {
			globalData.proposedLocation = nil;
			globalData.unsentReport.latitude = 0;
			globalData.unsentReport.longitude = 0;
			[[self reportLocationViewController] zoomToRegion:NO];		
		}
		self.reportLocationViewController.delegate = self;
		[self.tabBarController presentModalViewController:self.reportLocationViewController animated:YES];
		return;
	}
	
	// alert for report submitted successfully
	if ([alertView tag] == 2) {
		[self clearNewReportView];
		return;
	}
	
	// alert for report submittal failure
	if ([alertView tag] == 3) {
		// user got a network error during submittal... get rid of the progress view, it will be restored if they choose yes to retry
		[self.busyViewController.view removeFromSuperview];
		self.busyViewController = nil;
		if (buttonIndex == 0) {
			[self sendReportToTrackIT];
		} 
		return;
	}
	
	// alert for general network unavailability
	if ([alertView tag] == 4) {
		return;
	}
	
	// alert for general network unavailability
	if ([alertView tag] ==5) {
		return;
	}
	// alert for old report being submitted with now unsupported report type
	if ([alertView tag] == 6) {
		reportTypeIndex = -1;
		[[self chooseReportTypeButtonLabel] setText:@"Choose Report Type"];
		DataRepository.sharedInstance.unsentReport.reportType = nil;
		return;
	}
	// alert for report submittal failure due to server side issues
	if ([alertView tag] == 7) {
		// user got a network error during submittal... get rid of the progress view, it will be restored if they choose yes to retry
		[self.busyViewController.view removeFromSuperview];
		self.busyViewController = nil;
		return;
	}
	// alert for insufficent data to submit report
	if ([alertView tag] == 8) {
		return;
	}
	// alert for report location not in city
	if ([alertView tag] == 9) {
		return;
	}
	// alert for report types not available yet
	if ([alertView tag] == 10) {
		return;
	}
	// alert for report types not available yet
	if ([alertView tag] == 11) {
		return;
	}
	// alert for report types not available yet
	if ([alertView tag] == 12) {
		if (buttonIndex == 0) {
			[[DataRepository sharedInstance] switchActiveTab:2];
		}
		else {
			[self sendReportToTrackIT];
		}
		return;
	}
}


#pragma mark Report Location and Core Location methods

- (void)startGPSLocationAcquireLoop:(NSInteger)maximumNumberOfSamples sampleIntervalInSeconds:(NSInteger)intervalInSeconds;  {
	// show the application busy indicator
	if (self.busyViewController == nil) {
		AppBusyViewController *controller = [[AppBusyViewController alloc] initWithNibName:@"AppBusyView" bundle:nil];
		self.busyViewController = controller;
		[controller release];
	}
	[[[[[self view] superview] superview] superview] addSubview:self.busyViewController.view];
	NSString *labelText = [NSString stringWithFormat:@"Please wait, trying to get an accurate GPS fix for your location (currently ± %0.1f meters)",DataRepository.sharedInstance.proposedLocation.horizontalAccuracy];
	[[self.busyViewController activityIndicatorLabel] setText:labelText];
	[self.busyViewController startProgressIndicator];
	locationTimerFiredCount = 0;
	locationTimerMaximumCount = maximumNumberOfSamples;
	self.getLocationTimer = [NSTimer scheduledTimerWithTimeInterval:intervalInSeconds target:self selector:@selector(getGPSLocationTimerFired) userInfo:nil repeats:YES];
}

- (void)stopGPSLocationAcquireTimerLoop {
	[[self getLocationTimer] invalidate];
	[self.busyViewController stopProgressIndicator];
	[self.busyViewController.view removeFromSuperview];
	self.busyViewController = nil;
}

- (void)getGPSLocationTimerFired {
	
	locationTimerFiredCount++;
	CLLocation *location = [[self getGPSLocation]retain];
	DataRepository *globalData = [DataRepository sharedInstance];
	globalData.proposedLocation == location;
	Report *report = globalData.unsentReport;
	if (report != nil) {
		report.latitude = globalData.proposedLocation.coordinate.latitude;
		report.longitude = globalData.proposedLocation.coordinate.longitude;
	}
	[location release];
	
	if ([self isGPSLocationAccurateEnough:globalData.proposedLocation] == YES) {
		// current location is accurate enough, shut down the timer and stop looking for better location fixes
		[self stopGPSLocationAcquireTimerLoop];
		// this GPS location's accuracy meets our requirements, however we need to make sure it is within our area
		if ([globalData locationIsInCity:globalData.proposedLocation] == YES) {
			// we're golden, accept the location and continue
			return;
		}
		else {
		    // warn user that location is no good and they need to pick from the map
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unusable GPS Location"
																message:@"Your current GPS location appears to be outside of the City of Portland. To continue, you will need to choose a location directly on the map display"
															   delegate:self
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:1];
			[alertView show];
			[alertView release];
			return;
		}
	}
	else {
		// current location does not currently meet our accuracy requirements
		// check if we have polled for for the maximum amount of time, if so alert the user and go to plan 'B' on acquiring location
		if (locationTimerFiredCount >= locationTimerMaximumCount) {
			[self stopGPSLocationAcquireTimerLoop];
			// Also, make sure location with within the city
			if ([globalData locationIsInCity:globalData.proposedLocation] == YES) {
				// warn user that location is no good and they need to fine-tune it on map
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Refine Location"
																	message:[NSString stringWithFormat:@"Unable to get an accurate enough (± %0.1f meters) fix from your device's GPS. Please fine-tune your location on the map display by centering the crosshairs on your actual location.", DataRepository.sharedInstance.appSettings.requiredGPSAccuracyInMeters] 
																   delegate:self
													      cancelButtonTitle:@"OK" 
														  otherButtonTitles:nil];
				[alertView setTag:1];
				[alertView show];
				[alertView release];
				// when this alertview returns, a new view incorporating a map view will  
				// be placed on top of the current view in this alertViews delegate code.
				return;
			}
			else {
				// warn user that location is no good and they need to pick from the map
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unusable GPS Location"
																	message:@"Your current GPS location appears to be outside of the <some geographic area>. To continue, you will need to choose a location directly on the map display"
																   delegate:self
														  cancelButtonTitle:@"OK" 
														  otherButtonTitles:nil];
				[alertView setTag:1];
				[alertView show];
				[alertView release];
				return;
			}
		}
		else {
			// keep on polling for better locations, return
			NSString *labelText = [NSString stringWithFormat:@"Please wait, trying to get an accurate GPS fix for your location (currently ± %0.1f meters)",DataRepository.sharedInstance.proposedLocation.horizontalAccuracy];
			[[self.busyViewController activityIndicatorLabel] setText:labelText];
			return;
		}
	}
}

- (CLLocation *)getGPSLocation {
	LocationController *locationController = [LocationController sharedInstance];
	if ([locationController locationKnown] == NO) {
		return nil;
	}
	return [locationController currentLocation];
}

- (bool)isGPSLocationAccurateEnough:(CLLocation *)location {
	if (location == nil) {
		return NO;
	}	
	//NSNumber *accuracy = [NSNumber numberWithDouble:[location horizontalAccuracy]];
	//NSLog(@"Horizontal accuracy = %f meters",[location horizontalAccuracy]);
	if ([location horizontalAccuracy] <= DataRepository.sharedInstance.appSettings.requiredGPSAccuracyInMeters) {
		return YES;
	} else {
		return NO;
	}
}

#pragma mark HTTP request success/failure callbacks and supporting methods

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	
	if ([requestType isEqualToString:@"post_new_report"]) {
		bool reportSubmitalOK = NO;
		// get rid of the progress view
		[self.busyViewController.view removeFromSuperview];
		self.busyViewController = nil;
		if (request.responseStatusCode == 200) {
		    NSString *response = [request responseString];
			if ([self parseReportSentXml:response] == YES)
			{
				reportSubmitalOK = YES;
				DataRepository.sharedInstance.myReportsShouldBeRefreshed = YES;
				UIAlertView *alertView = [[UIAlertView alloc] 
										  initWithTitle:@"Report Sent"
										  message:@"Thank you, your report has been submitted. You can track it on the 'My Reports' screen." 
										  delegate:self 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
				[alertView setTag:2];
				[alertView show];
				[alertView release];
			}
		}
		if (reportSubmitalOK == NO) {
			UIAlertView *alertView = [[UIAlertView alloc] 
									  initWithTitle:@"Send Report Failed"
									  message:@"An error with <some organization's> website was encountered while sending your report. Please try sending it again later." 
									  delegate:self 
									  cancelButtonTitle:@"OK"
									  otherButtonTitles:nil];
			[alertView setTag:7];
			[alertView show];
			[alertView release];		
		}
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	
	if ([requestType isEqualToString:@"post_new_report"]) {
		
		if ([[DataRepository sharedInstance] internetIsReachableRightNow] == NO || DataRepository.sharedInstance.connectionRequiredForInternet == YES) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
																message:@"Unable to submit report, your device is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:7];
			[alertView show];	
			[alertView release];
			return;		
		}
		else {
			sendReportBackgroundRetryCount++;
			if (sendReportBackgroundRetryCount <= 3) {
				if (sendReportBackgroundRetryCount == 1) {
					if ([self cityWebServerIsReachable]==NO) {
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable To Send Report"
																			message:@"The <organization's> webserver is not currently reachable from this device. Please try sending your report again later." 
																		   delegate:self 
																  cancelButtonTitle:@"OK" 
																  otherButtonTitles:nil];
						[alertView setTag:7];
						[alertView show];
						[alertView release];	
						return;						
					}
				}
				[self sendReportToTrackIT]; // background retry sending the report up to 3 times, on the 4th, ask the user if they want to retry
				return;
			}
			else {
				UIAlertView *alertView = [[UIAlertView alloc] 
										  initWithTitle:@"Send Report Failed"
										  message:@"An unknown network error was encountered while sending your report. Would you like to try sending it again?" 
										  delegate:self 
										  cancelButtonTitle:nil
										  otherButtonTitles:@"YES", @"NO", nil];
				[alertView setTag:3];
				[alertView show];
				[alertView release];
				return;
			}
		}
	}
}

- (bool)parseReportSentXml:(NSString *)xmlData {
	
	bool returnValue = NO;
	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		DDXMLNode *rootNode = [xmlDocument rootElement];
		if ([rootNode childCount] == 1) {
			DDXMLNode *childNode = [rootNode childAtIndex:0];
			if ([[[childNode name] lowercaseString] isEqualToString:@"item_id"]) {
				if ([[childNode stringValue] length] > 0) {
					Report *newReport = [[Report alloc]init];
					[[DataRepository sharedInstance] setUnsentReport:newReport];
					[newReport release];
					returnValue = YES;
				}
			}
		}
	}
	if (xmlDocument != nil) {
		[xmlDocument release];
	}
	return returnValue;
}

@end
