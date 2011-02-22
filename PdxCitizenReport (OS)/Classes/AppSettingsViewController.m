//
//  AppSettingsViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/7/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
	// if the code gets here, data has changed trim, cache and upload it
    if (nameTextField.text.length > 100)
        nameTextField.text = [nameTextField.text substringToIndex:100];
    if (emailAddressTextField.text.length > 100)
        emailAddressTextField.text = [emailAddressTextField.text substringToIndex:100];
    if (phoneNumberTextField.text.length > 30)
        phoneNumberTextField.text = [phoneNumberTextField.text substringToIndex:30];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
}

// get the keyboard to go away
-(bool)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


#pragma mark limit length of contact inputs to sane values

// limit input within allowable range
- (bool)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
    if (textField == phoneNumberTextField)
    {
        // limit the name and email fields to 100 in length
        if (textField.text.length >= 12 && range.length == 0)
            return NO;
        else
            
            return YES;
    }
    else
    {
        // limit the name and email fields to 100 in length
        if (textField.text.length >= 100 && range.length == 0)
            return NO;
        else
            
            return YES;    
    }
}

- (IBAction)uiTextFieldChangedDueToEdit:(id)sender {
    
    if (ignoreUiTextFieldChangedEvent)
        return;
    
    // insert some formatting into the phone number field and remove keyboard when it looks like we have a reasonable pattern
    if (sender == phoneNumberTextField) {
        UITextField *textField = (UITextField *)sender;
        NSString *interimString = textField.text;
        interimString = [interimString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if ([[DataRepository sharedInstance] stringIsUnsignedInt:interimString] == YES)
        {
            if (interimString.length > 3)
            {
                if (interimString.length > 6) 
                {
                    NSString *areaCode = [interimString substringWithRange:NSMakeRange(0,3)];
                    NSString *prefix = [interimString substringWithRange:NSMakeRange(3,3)];
                    NSString *suffix = [interimString substringFromIndex:6];
                    ignoreUiTextFieldChangedEvent = true;
                    textField.text = [NSString stringWithFormat:@"%@-%@-%@",areaCode,prefix,suffix];
                    ignoreUiTextFieldChangedEvent = false;
                    if (textField.text.length == 12)
                        [textField resignFirstResponder];
                } 
                else
                {
                    NSString *part1 = [interimString substringWithRange:NSMakeRange(0, 3)];
                    NSString *part2 = [interimString substringFromIndex:3];
                    ignoreUiTextFieldChangedEvent = true;
                    textField.text = [NSString stringWithFormat:@"%@-%@",part1,part2];
                    ignoreUiTextFieldChangedEvent = false;
                }
            }
            else
            {
                ignoreUiTextFieldChangedEvent = true;
                textField.text = interimString;
                ignoreUiTextFieldChangedEvent = false;
            }
        }
        else
        {
            ignoreUiTextFieldChangedEvent = true;
            textField.text = interimString;
            ignoreUiTextFieldChangedEvent = false;
        }
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
		[request setTimeOutSeconds:60];
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
