//
//  ReportDetailWebViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/10/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
