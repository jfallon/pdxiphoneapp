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
@synthesize button;
@synthesize delegate;

- (IBAction)finishReportCommentsFromButtonClick:(id)sender {
	[[self commentsTextView] resignFirstResponder];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// set background image of UIButtons, this is done at runtime because the images are dynamically stretched based on button size
	[button setBackgroundImage:[[UIImage imageNamed:@"grayButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
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

- (void)dealloc {
	[commentsTextView release]; commentsTextView = nil;
	[button release]; button = nil;
	[super dealloc];
}

@end
