//
//  ReportCommentsViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
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
