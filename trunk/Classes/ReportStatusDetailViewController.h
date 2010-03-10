//
//  ReportStatusDetailViewController.h
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


@interface ReportStatusDetailViewController : UIViewController <UIWebViewDelegate> {
	
	NSURL *detailURL;
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIWebView *webViewControl;
	bool pageLoaded;
}

@property (nonatomic,retain) NSURL *detailURL;
@property (nonatomic,retain) IBOutlet UIWebView *webViewControl;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;

- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;


@end
