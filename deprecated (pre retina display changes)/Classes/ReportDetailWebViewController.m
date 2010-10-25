//
//  ReportDetailWebViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/10/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "ReportDetailWebViewController.h"
#import "DataRepository.h"


@implementation ReportDetailWebViewController

@synthesize url;
@synthesize webViewControl;
@synthesize activityView;
@synthesize internetUnavailableMessage;


//The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithURL:(NSURL *)initialURL andAllowPageLinks:(bool)allowLinks fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.url = initialURL;
		enablePageLinks = allowLinks;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	pageLoaded = NO;
	DataRepository *globalData = [DataRepository sharedInstance];
	if ([globalData internetIsReachableRightNow] == YES && globalData.connectionRequiredForInternet == NO) {
		if (self.url != nil) {
			NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
			[self.webViewControl loadRequest:request];
			pageLoaded = YES;
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	self.internetUnavailableMessage.hidden = pageLoaded;
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


- (void)dealloc {
	[url release]; url = nil;
	[webViewControl release]; webViewControl = nil;
	[activityView release]; activityView = nil;
    [super dealloc];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return enablePageLinks;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[self activityView] startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[self activityView] stopAnimating];
}


@end
