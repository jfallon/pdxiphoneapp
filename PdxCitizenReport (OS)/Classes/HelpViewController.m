//
//  HelpViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "HelpViewController.h"
#import "DataRepository.h"
#import "AppSettings.h"


@implementation HelpViewController

@synthesize webViewControl;
@synthesize activityView;

- (void)dealloc {
	[webViewControl release]; webViewControl = nil;
	[activityView release]; activityView = nil;
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	pageLoaded = NO;
	DataRepository *globalData = [DataRepository sharedInstance];
	if ([globalData internetIsReachableRightNow] == YES && globalData.connectionRequiredForInternet == NO) {
		if (globalData.appSettings.helpPageAddress.length > 0) {
			NSURL *url = [NSURL URLWithString:globalData.appSettings.helpPageAddress];
			NSURLRequest *request = [NSURLRequest requestWithURL:url];
			[self.webViewControl loadRequest:request];
			pageLoaded = YES;
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	if (pageLoaded == NO) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable"
															message:@"Unable to load help page, your iPhone is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:0];
		[alertView show];	
		[alertView release];
		return;
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[self activityView] startAnimating];
	self.activityView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	self.activityView.hidden = YES;
	[[self activityView] stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
        return YES;
    else
    {
        NSString *thisRequestString = [[[request URL] absoluteString] lowercaseString] ;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:thisRequestString]];
        return NO;
    }
}
             
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	
}
@end
