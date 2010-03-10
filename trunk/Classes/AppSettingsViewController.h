//
//  AppSettingsViewController.h
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
@class ASIHTTPRequest;

@interface AppSettingsViewController : UIViewController <UITextFieldDelegate> {

	IBOutlet UITextField *nameTextField;
	IBOutlet UITextField *emailAddressTextField;
	IBOutlet UITextField *phoneNumberTextField;
	NSInteger postContactInfoRetryCount;
}

@property(nonatomic,retain) IBOutlet UITextField *nameTextField;
@property(nonatomic,retain) IBOutlet UITextField *emailAddressTextField;
@property(nonatomic,retain) IBOutlet UITextField *phoneNumberTextField;

- (bool)textFieldShouldReturn:(UITextField *)textField;
- (bool)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (void)uploadUserContactInfo;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
