//
//  HelpViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {

	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIWebView *webViewControl;
	bool pageLoaded;
}

@property (nonatomic,retain) IBOutlet UIWebView *webViewControl;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityView;

- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
