//
//  ReportStatusDetailViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/8/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
