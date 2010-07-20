//
//  AppSettingsViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "AppSettingsViewController.h"
#import "DataRepository.h"
#import "AppSettings.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "AppSettings.h"

@implementation AppSettingsViewController


@synthesize nameTextField;
@synthesize emailAddressTextField;
@synthesize phoneNumberTextField;

- (void)dealloc {
	[nameTextField release]; nameTextField = nil;
	[emailAddressTextField release]; emailAddressTextField = nil;
	[phoneNumberTextField release]; phoneNumberTextField = nil;
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	AppSettings *appSettings = DataRepository.sharedInstance.appSettings;
	if (appSettings.userSettingsApplied == NO) {
		nameTextField.text = appSettings.userName;
		emailAddressTextField.text = appSettings.userEmailAddress;
		phoneNumberTextField.text = appSettings.userTelephoneNumber;
		appSettings.userSettingsApplied = YES;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	AppSettings *appSettings = DataRepository.sharedInstance.appSettings;
	if ([nameTextField.text isEqualToString:appSettings.userName]) {
		if ([emailAddressTextField.text isEqualToString:appSettings.userEmailAddress]) {
			if ([phoneNumberTextField.text isEqualToString:appSettings.userTelephoneNumber]) {
				return;
			}
		}
	}
	// if the code gets here, data has changed cache and upload it
	appSettings.userName = nameTextField.text;
	appSettings.userEmailAddress = emailAddressTextField.text;
	appSettings.userTelephoneNumber = phoneNumberTextField.text;
	[self uploadUserContactInfo];
	
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// get the keyboard to go away
-(bool)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


#pragma mark limit length of contac inputs to sane values

// limit input within allowable range
- (bool)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSInteger maxLength;
	switch (textField.tag) {
		case 0: // "fullName":
			maxLength = 100;
			break;
		case 1: // "phoneNumber":
			maxLength = 30;
			break;
		case 2: // "emailAddress":
			maxLength = 100;
			break;
		default:
			break;
	}
	if (textField.text.length >= maxLength && range.length == 0) {
		return NO;
	}
	else {
		return YES;
	}
}

#pragma mark send contact info

- (void)uploadUserContactInfo {
	if (DataRepository.sharedInstance.internetIsReachable == YES) {
		NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] sendContactInfoUrlSuffix]];
		NSURL *url = [NSURL URLWithString:address];
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
		[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
		[request setPostValue:[[DataRepository sharedInstance] deviceID] forKey:@"device_id"];
		[request setPostValue:[[[DataRepository sharedInstance] appSettings] userName] forKey:@"full_name"];
		[request setPostValue:[[[DataRepository sharedInstance] appSettings] userEmailAddress] forKey:@"email_address"];
		[request setPostValue:[[[DataRepository sharedInstance] appSettings] userTelephoneNumber] forKey:@"phone_number"];
		[request setUserInfo:[NSDictionary dictionaryWithObject:@"post_contact_info" forKey:@"request_type"]];
		[request setTimeOutSeconds:30];
		[request setDelegate:self];
		[request startAsynchronous];
	}
}

#pragma mark HTTP request success/failure callbacks and supporting methods

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"post_contact_info"]) {
		if (request.responseStatusCode == 200) {
			NSString *response = [request responseString];
			NSRange textRange;
			textRange = [[response lowercaseString] rangeOfString:@"updated"];
			if (textRange.location == NSNotFound) {
				// something happened and user info wasn't updated
			}
		}
	}
}
- (void)requestFailed:(ASIHTTPRequest *)request {
	
	if (request.error != nil) {	
		//NSLog(@"Error code = %ld",(long)request.error.code);
	}
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"post_contact_info"]) {
		//NSLog(@"Post contact info HTTP request failed");
		postContactInfoRetryCount++;
		if (postContactInfoRetryCount <= 3) {
			//NSLog(@"Retry Attempt #%ld",(long)postContactInfoRetryCount);
			[self uploadUserContactInfo];			
		}
		else {
			//NSLog(@"Giving up after %ld attempts",(long)postContactInfoRetryCount);
		}
	}
}



@end
