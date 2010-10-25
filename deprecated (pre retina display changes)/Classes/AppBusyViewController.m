//
//  AppBusyViewController.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppBusyViewController.h"


@implementation AppBusyViewController

@synthesize activityIndicatorView;
@synthesize activityIndicatorLabel;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[activityIndicatorView release]; activityIndicatorView = nil;
	[activityIndicatorLabel release]; activityIndicatorLabel = nil;
    [super dealloc];
}

- (void)startProgressIndicator {
	[activityIndicatorView startAnimating];
}
- (void)stopProgressIndicator {
	[activityIndicatorView stopAnimating];
}

@end
