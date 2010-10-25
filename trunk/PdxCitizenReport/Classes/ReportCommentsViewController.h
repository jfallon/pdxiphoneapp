//
//  ReportCommentsViewController.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReportCommentsViewController;

@protocol ReportCommentsViewControllerDelegate <NSObject>
- (void)reportCommentsViewControllerDidResign:(ReportCommentsViewController *)controller;
@end

@interface ReportCommentsViewController : UIViewController <UITextViewDelegate> {

	IBOutlet UITextView		*commentsTextView;
	IBOutlet UIButton		*button;
	id<ReportCommentsViewControllerDelegate> delegate;
}

@property (nonatomic,retain) IBOutlet UITextView *commentsTextView;
@property (nonatomic,retain) IBOutlet UIButton *button;
@property(assign)id<ReportCommentsViewControllerDelegate> delegate;

- (IBAction)finishReportCommentsFromButtonClick:(id)sender;

// required by UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;

@end
