//
//  AppSettingsViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 1/7/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;

@interface AppSettingsViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate> {

	IBOutlet UITextField *nameTextField;
	IBOutlet UITextField *emailAddressTextField;
	IBOutlet UITextField *phoneNumberTextField;
	NSInteger postContactInfoRetryCount;
    bool ignoreUiTextFieldChangedEvent;
}

@property(nonatomic,retain) IBOutlet UITextField *nameTextField;
@property(nonatomic,retain) IBOutlet UITextField *emailAddressTextField;
@property(nonatomic,retain) IBOutlet UITextField *phoneNumberTextField;


- (IBAction)uiTextFieldChangedDueToEdit:(id)sender;

// UIAlertViewDelegate protocol
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// UITextFieldDelegate protocol
- (bool)textFieldShouldReturn:(UITextField *)textField;
- (bool)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

- (void)uploadUserContactInfo;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
