//
//  ReportCommentsViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import <Foundation/Foundation.h>

@class ReportCommentsViewController;

@protocol ReportCommentsViewControllerDelegate <NSObject>
- (void)reportCommentsViewControllerDidResign:(ReportCommentsViewController *)controller;
@end

@interface ReportCommentsViewController : UIViewController <UITextViewDelegate> {

	IBOutlet UITextView		*commentsTextView;
	id<ReportCommentsViewControllerDelegate> delegate;
}

@property (nonatomic,retain) IBOutlet UITextView *commentsTextView;
@property(assign)id<ReportCommentsViewControllerDelegate> delegate;

- (IBAction)finishReportCommentsFromButtonClick:(id)sender;

// required by UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;

@end
