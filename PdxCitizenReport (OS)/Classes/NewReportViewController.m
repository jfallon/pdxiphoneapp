//
//  NewReportViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "NewReportViewController.h"
#import "LocationController.h"
#import "AppBusyViewController.h"
#import "AppProgressViewController.h"
#import "Report.h"
#import "CRMReportDefinition.h"
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
@synthesize setReportPhotoButton;
@synthesize setReportTypeButton;
@synthesize setReportLocationButton;
@synthesize cancelReportButton;
@synthesize submitReportButton;
@synthesize reportCommentsTextView;
@synthesize currentActionSheet;
@synthesize commentsActivityView;
@synthesize reportTypePickerView;
@synthesize busyViewController;
@synthesize progressViewController;
@synthesize getLocationTimer;
@synthesize longTextViewController;
@synthesize reportLocationViewController;
@synthesize reportCommentsViewController;

#pragma mark UIViewController method overloads 

- (void)dealloc {
	[commentsActivityView release]; commentsActivityView = nil;
	[imageView release]; imageView = nil;
	[reportCommentsTextView release]; reportCommentsTextView = nil;
	[currentActionSheet release]; currentActionSheet = nil;
	[setReportPhotoButton release]; setReportPhotoButton = nil;
	[setReportTypeButton release]; setReportTypeButton = nil;
	[setReportLocationButton release]; setReportLocationButton = nil;
	[cancelReportButton release]; cancelReportButton = nil;
	[submitReportButton release]; submitReportButton = nil;
	[reportTypePickerView release]; reportTypePickerView = nil;
	[busyViewController release]; busyViewController = nil;
	[progressViewController release]; progressViewController = nil;
	[getLocationTimer release]; getLocationTimer = nil;
	[longTextViewController release]; longTextViewController = nil;
	[reportLocationViewController release]; reportLocationViewController = nil;
	[reportCommentsViewController release]; reportCommentsViewController = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	reportTypeIndex = -1;
	
	// set background image of UIButtons, this is done at runtime because the images are dynamically stretched based on button size
	[setReportPhotoButton setBackgroundImage:[[UIImage imageNamed:@"grayButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
	[setReportTypeButton setBackgroundImage:[[UIImage imageNamed:@"grayButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
	[setReportLocationButton setBackgroundImage:[[UIImage imageNamed:@"grayButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
	[cancelReportButton setBackgroundImage:[[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
	[submitReportButton setBackgroundImage:[[UIImage imageNamed:@"greenButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];

	// register to be notified if/when app delegate gets [applicationWillEnterForeground] message
	[[NSNotificationCenter defaultCenter] addObserver:self 
										selector:@selector(applicationComingToForeground)
										name:NOTIF_AppComingToForeground
										object:nil];
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	
	//NSLog(@"New Report View Appeared...");
	
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
				[[self setReportTypeButton] setTitle:unsentReport.reportType forState:UIControlStateNormal];
			}
			if ([unsentReport latitude] !=0 && [unsentReport longitude] !=0) {
				CLLocation  *proposedLocation = [[CLLocation alloc] initWithLatitude:[unsentReport latitude] longitude:[unsentReport longitude]];
				[[DataRepository sharedInstance] setProposedLocation:proposedLocation];
				[proposedLocation release];
				[[self setReportLocationButton] setTitle:@"Change Report Location" forState:UIControlStateNormal];
			}
		}
	}
	
	if (disclaimerHasBeenDisplayedOnce == NO) {
		[self displayUsageWarning];
		disclaimerHasBeenDisplayedOnce = YES;
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

- (void)applicationComingToForeground {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	
	// stuff to do if the app has been backgrounded for 30 minutes or more
	if (globalData.numberOfSecondsBackgrounded >= 1800)
	{
		// clear out any location that was cached as part of an unsent report
		globalData.proposedLocation = nil;
		if (globalData.unsentReport != nil)
		{
			globalData.unsentReport.latitude = 0;
			globalData.unsentReport.longitude = 0;
			globalData.unsentReport.horizontalAccuracyInMeters = 0;
		}
	}
	
	// conditionally reset the caption on the "Set Location" button if the 
	// unsent report either a) no longer exits or b) does not have a valid location anymore
	if (globalData.unsentReport == nil) {
		[[self setReportLocationButton] setTitle:@"Set Report Location" forState:UIControlStateNormal];						
	}
	else {
		if (globalData.unsentReport.latitude == 0 && globalData.unsentReport.longitude == 0) {
			[[self setReportLocationButton] setTitle:@"Set Report Location" forState:UIControlStateNormal];				
		}
	}
	
	// stuff to do if the app has been backgrounded for 24 hours or more
	if (globalData.numberOfSecondsBackgrounded >= 86400)
	{		
		// display the usage warning and if needed switch to new report view
		if (globalData.getActiveTabIndex == 0) {
			[self displayUsageWarning];
		}
		else {
			disclaimerHasBeenDisplayedOnce = NO;
			[globalData switchActiveTab:0];
		}
	}
}

- (void)displayUsageWarning {
	
	AppSettings *settings = DataRepository.sharedInstance.appSettings;
	if (self.longTextViewController == nil) {
		self.longTextViewController = [[AppLongTextViewController alloc] initWithNibName:@"AppLongTextView" bundle:nil];
	}
	[[[[[self view] superview] superview] superview] addSubview:self.longTextViewController.view];
	UITextView *textView = self.longTextViewController.textView;
	[textView setText:nil];
	[textView setText:settings.usageWarningText];
	[textView setEditable:NO];
	[textView setDataDetectorTypes:UIDataDetectorTypeAll];
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

- (IBAction)showSetReportLocationViewFromButtonClick:(id)sender {
	
	DataRepository *globalData = [DataRepository sharedInstance];
	if (self.reportLocationViewController == nil) {
		self.reportLocationViewController = [[SetReportLocationViewController alloc] initWithNibName:@"SetReportLocationView" bundle:nil];
	}
	
	// don't overwrite an existing, saved location
	if (globalData.proposedLocation == nil) {
		[globalData setProposedLocation:[self getGPSLocation]];
	}
	
	// set the lat/long of the unsent report
	if (globalData.proposedLocation != nil) {
		globalData.unsentReport.latitude = globalData.proposedLocation.coordinate.latitude;
		globalData.unsentReport.longitude = globalData.proposedLocation.coordinate.longitude;
	}
	else {
		globalData.unsentReport.latitude = 0;
		globalData.unsentReport.longitude = 0;
		globalData.unsentReport.horizontalAccuracyInMeters = 0;
	}
	
	// validate that proposed location is in city. if yes, zoom to it, if not, zoom to region
	if ([globalData locationIsInCity:globalData.proposedLocation] == YES) {
		[[self reportLocationViewController] zoomToProposedLocation:NO];
	}	
	else {
		globalData.proposedLocation = nil;
		globalData.unsentReport.latitude = 0;
		globalData.unsentReport.longitude = 0;
		globalData.unsentReport.horizontalAccuracyInMeters = 0;
		[[self reportLocationViewController] zoomToRegion:NO];		
	}
	self.reportLocationViewController.delegate = self;
	[self.tabBarController presentModalViewController:self.reportLocationViewController animated:YES];
	return;
}

#pragma mark Set Location View Controller callbacks

// callback from set report location view indicating how user left that screen
- (void)setReportLocationViewControllerDidCancel:(SetReportLocationViewController *)controller {
	[reportLocationViewController release]; reportLocationViewController = nil;
}

// callback from set report location view indicating how user left that screen
- (void)setReportLocationViewControllerDidSaveLocation:(SetReportLocationViewController *)controller {
	[[self setReportLocationButton] setTitle:@"Change Report Location" forState:UIControlStateNormal];	
	[reportLocationViewController release]; reportLocationViewController = nil;
}


#pragma mark UIActionSheet callback

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// action sheet used to choose photo (camera or library) source on devices with cameras
	if (actionSheet.tag == 0) {
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
	UIImage *resizedImage = [image th_resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
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
	if (globalData.crmReportDefinitionArray.count == 0) {
		if (globalData.internetIsReachable == YES && globalData.connectionRequiredForInternet == NO) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Types Unavailable"
																message:@"The list of valid report types have not reached your iPhone yet. Please press OK, wait a couple seconds, then try again." 
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
	if (reportTypeIndex != -1 && reportTypeIndex <= [[[DataRepository sharedInstance]crmReportDefinitionArray]count]) {
		[reportTypePickerView selectRow:reportTypeIndex inComponent:0 animated:NO];
	}
}

- (void)reportTypeActionSheetSaveButtonClick {
	
	if (currentActionSheet != nil) {
		reportTypeIndex = [reportTypePickerView selectedRowInComponent:0];
		NSString *reportType = nil;
		//NSString * buttonTitle = nil;
		CRMReportDefinition *instance = nil;
		if (reportTypesLoaded == YES) {
			instance = [[[DataRepository sharedInstance] crmReportDefinitionArray] objectAtIndex:reportTypeIndex];
			reportType = [NSString stringWithString:[instance instanceName]];
			[[[DataRepository sharedInstance] unsentReport] setReportType:reportType];
			[[self setReportTypeButton] setTitle:reportType forState:UIControlStateNormal];
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
		CRMReportDefinition *instance = [[[DataRepository sharedInstance] crmReportDefinitionArray] objectAtIndex:row];
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
		NSMutableArray *instanceArray = [[DataRepository sharedInstance] crmReportDefinitionArray];
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
	AppSettings *settings = DataRepository.sharedInstance.appSettings;

	CRMReportDefinition *instance = nil;
	if (reportTypeIndex == -1) {
		NSMutableArray *trackItInstanceArray = globalData.crmReportDefinitionArray;
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
	if (reportTypeIndex >= 0  && (reportTypeIndex <= (globalData.crmReportDefinitionArray.count - 1))) {
		instance = [[globalData crmReportDefinitionArray] objectAtIndex:reportTypeIndex];
	}
	else {
		instance = nil;
	}
	
	if (globalData.deviceIsBlackListed == YES) {
		NSString *blackListMessage = nil;
		if ([[[globalData blackListReason] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0) {
			blackListMessage = [NSString stringWithFormat:@"This iPhone has been blocked from submitting reports, the following reason was recorded: '%@'. If you feel this is in error, please contact the %@ at %@ for assistance.", DataRepository.sharedInstance.blackListReason, DataRepository.sharedInstance.agencyName, DataRepository.sharedInstance.agencyPhoneNumber];
		}
		else {
			blackListMessage = [NSString stringWithFormat:@"This device has been blocked from submitting reports. If you feel this is in error, please contact the %@ at %@ for assistance.", DataRepository.sharedInstance.agencyName, DataRepository.sharedInstance.agencyPhoneNumber];
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
	
	// check for contact info completeness
	bool contactInfoComplete = YES;
	if (settings.userName.length == 0) {
		contactInfoComplete = NO;  // no name, contact info incomplete
	}
	else {
		if ((settings.userEmailAddress.length == 0) && (settings.userTelephoneNumber.length == 0)) {
			contactInfoComplete = NO;  // there is a name, but email and phone are both blank, contact info incomplete
		}
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
			NSString *contactInfoRequired = [NSString stringWithFormat:@"%@", (instance.contactInfoRequired ? @"Contact Info\n" : @"")];
			
			incompleteReportMessage = [NSString stringWithFormat:@"%@%@%@%@%@",messagePrefix,imageRequired,addressRequired,commentsRequired,contactInfoRequired];
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
			if (instance.contactInfoRequired == YES) {
				if (contactInfoComplete == NO) {
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
																message:[NSString stringWithFormat:@"Unable to submit your report, the specified location is outside of the %@", globalData.agencyName]
															   delegate:self 
													  cancelButtonTitle:@"OK" 
													  otherButtonTitles:nil];
			[alertView setTag:9];
			[alertView show];	
			[alertView release];
			return;
		}
	}
	
	// determines if nag screen code will run based on the last time it ran
	bool showNagScreen = YES;  // initally be pesimistic and assume the nag screen code will be run
	if (settings.lastNagForContactInfoDate != nil) {
		NSTimeInterval interval = [settings.lastNagForContactInfoDate timeIntervalSinceNow];
		if (fabs(interval) < 86400) {
			// the nag was shown less than 24 hours ago, don't run the nag screen code
			showNagScreen = NO;
		}
	}

	// this block determines if a nag screen will be shown based on existance of contact info
	if (showNagScreen == YES) {
		showNagScreen = NO; // reset flag and check for sufficient contact info
		if (contactInfoComplete == NO) {
			showNagScreen = YES;
		}

		if (showNagScreen == YES) {
			settings.lastNagForContactInfoDate = [NSDate date];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Contact Info?"
																message:@"Please consider filling out the contact information found on the 'Contact Info' tab of this app.  While contact information is optional, it helps us respond to reports more effectively. Would you like to fill out your contact information now?" 
															   delegate:self 
													  cancelButtonTitle:nil
													  otherButtonTitles:@"Yes", @"No", nil];
			[alertView setTag:12];
			[alertView show];	
			[alertView release];
			return;		
		}
	}
	
	if ([[DataRepository sharedInstance] internetIsReachableRightNow] == NO || DataRepository.sharedInstance.connectionRequiredForInternet == YES) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Unavailable"
															message:@"Unable to submit report, your iPhone is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
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
	
	// set  up the UI to represent the app being busy while uploading report
	if (self.busyViewController == nil) {
		AppBusyViewController *controller = [[AppBusyViewController alloc] initWithNibName:@"AppBusyView" bundle:nil];
		self.busyViewController = controller;
		[controller release];
		
		[[[[[self view] superview] superview] superview] addSubview:self.busyViewController.view];
		NSString *labelText = [NSString stringWithFormat:@"Please wait, currently uploading your report to the %@...", globalData.agencyName];
		[[self.busyViewController activityIndicatorLabel] setText:labelText];
		[self.busyViewController startProgressIndicator];
	}
	
	// locate the report type in the report type array, this is used to determine form post parameter names
	if (reportTypeIndex == -1 ) {
		NSMutableArray *trackItInstanceArray = globalData.crmReportDefinitionArray;
		if (trackItInstanceArray.count > 0) {
			int i, count = [trackItInstanceArray count];
			for (i = 0; i < count; i++) {
				CRMReportDefinition *instance = [trackItInstanceArray objectAtIndex:i];
				NSString *instanceName = instance.instanceName;
				NSString *reportType = globalData.unsentReport.reportType;
				if ([instanceName isEqualToString:reportType]) {
					reportTypeIndex = i;
					break;
				}
			}
		}
	}			
	
	bool crmInstanceMissing = NO;
	CRMReportDefinition *instance = nil;
	if (reportTypeIndex < 0) {
		crmInstanceMissing = YES;
	}
	else {
		instance = [[globalData crmReportDefinitionArray] objectAtIndex:reportTypeIndex];
		if (instance == nil) {
			crmInstanceMissing = YES;
		}
	}
	
	if (crmInstanceMissing == YES) {
		// edge case: someone created a report but never sent it, later when they try to send it, that report type is no longer supported
		UIAlertView *alertView = [[UIAlertView alloc] 
								  initWithTitle:@"Send Report Failed"
								  message:[NSString stringWithFormat:@"The report type you originally selected for this unsent report is no longer available in %@.  Please choose a different report type and submit again.",globalData.appName]
								  delegate:self 
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil];
		[alertView setTag:6];
		[alertView show];
		[alertView release];
		return;
	}
	
	
	// now do a fast but blocking network check to verify we can hit the server endpoint, not continuing if this fails
	if ([self cityWebServerIsReachable]==NO) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable To Send Report"
															message:[NSString stringWithFormat:@"The %@ webserver is not currently reachable from this iPhone. Please try sending your report later.",globalData.agencyName] 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:7];
		[alertView show];
		[alertView release];	
		return;	
	}
	
	// city server was reached, configure the form post 
	NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] sendUserReportToCRMUrlSuffix]];
	NSURL *url = [NSURL URLWithString:address];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:globalData.verifyValue forKey:@"verify"];
	[request setPostValue:globalData.deviceID forKey:@"device_id"];
	[request setPostValue:globalData.deviceManufacturer forKey:@"device_manufacturer"];
	[request setPostValue:globalData.deviceModel forKey:@"device_model"];
	[request setPostValue:globalData.deviceOsName forKey:@"device_os_name"];
	[request setPostValue:globalData.deviceOsVersion forKey:@"device_os_version"];
	[request setPostValue:[NSString stringWithFormat:@"%ld",(long)instance.number] forKey:@"track_id"];
	[request setPostValue:[NSString stringWithFormat:@"%ld",(long)instance.category] forKey:@"category_id"];
	[request setPostValue:globalData.unsentReport.comments  forKey:instance.commentsFieldName];
	[request setPostValue:globalData.unsentReport.streetAddress forKey:instance.addressFieldName];			
	[request setPostValue:[NSString stringWithFormat:@"%f",globalData.unsentReport.longitude] forKey:instance.xCoordFieldName];
	[request setPostValue:[NSString stringWithFormat:@"%f",globalData.unsentReport.latitude] forKey:instance.yCoordFieldName];
	[request setUserInfo:[NSDictionary dictionaryWithObject:@"post_new_report" forKey:@"request_type"]];
	
	// add the image if one exists
	if (globalData.unsentReport.image != nil) {
		NSData *imageData = UIImageJPEGRepresentation(globalData.unsentReport.image, globalData.appSettings.jpegCompressionFactor);
		[request setData:imageData withFileName:@"report_photo.jpg" andContentType:@"image/jpeg" forKey:instance.imageFieldName];
		[request setTimeOutSeconds:90];
	} else {
		[request setTimeOutSeconds:60];
	}
	
	// set request callback and execute
	[request setDelegate:self];
	[request startAsynchronous];

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
	[[self setReportTypeButton] setTitle:@"Choose Report Type" forState:UIControlStateNormal];
	[[self setReportLocationButton] setTitle:@"Set Report Location" forState:UIControlStateNormal];
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
			globalData.unsentReport.horizontalAccuracyInMeters = 0;
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
		[[self setReportTypeButton] setTitle:@"Choose Report Type" forState:UIControlStateNormal];
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
			//NSLog(response);
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
									  message:[NSString stringWithFormat:@"An error with the %@ website was encountered while sending your report. Please try sending it again later.", DataRepository.sharedInstance.agencyName] 
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
																message:@"Unable to submit report, your iPhone is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
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
																			message:[NSString stringWithFormat:@"The %@ webserver is not currently reachable from this iPhone. Please try sending your report again later.",DataRepository.sharedInstance.agencyName]
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
