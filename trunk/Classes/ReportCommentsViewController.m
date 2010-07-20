//
//  ReportCommentsViewController.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ReportCommentsViewController.h"
#import "DataRepository.h"
#import "Report.h"


@implementation ReportCommentsViewController

@synthesize commentsTextView;
@synthesize delegate;

- (IBAction)finishReportCommentsFromButtonClick:(id)sender {

	[[self commentsTextView] resignFirstResponder];	
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	DataRepository *globalData = [DataRepository sharedInstance];
	[[self commentsTextView] setText:globalData.unsentReport.comments];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[[[DataRepository sharedInstance] unsentReport] setComments:[[self commentsTextView] text]];	
	if (self.delegate != nil) {
		if ([self.delegate respondsToSelector:@selector(reportCommentsViewControllerDidResign:)]) {
			[delegate reportCommentsViewControllerDidResign:self];
		}
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
