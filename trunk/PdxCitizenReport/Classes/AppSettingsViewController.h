//
//  AppSettingsViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/7/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
