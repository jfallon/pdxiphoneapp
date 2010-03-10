//
//  ReportDetailWebViewController.h
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


@interface ReportDetailWebViewController : UIViewController <UIWebViewDelegate> {
	
	NSURL *url;
	IBOutlet UIWebView *webViewControl;
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UILabel *internetUnavailableMessage;
	bool pageLoaded;
	bool enablePageLinks;
}

@property (nonatomic,retain) NSURL *url;
@property (nonatomic,retain) IBOutlet UIWebView *webViewControl;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,retain) IBOutlet UILabel *internetUnavailableMessage;

- (id)initWithURL:(NSURL *)initialURL andAllowPageLinks:(bool)allowLinks fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil;

- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;


@end
