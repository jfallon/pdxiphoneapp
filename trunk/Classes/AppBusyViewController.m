//
//  AppBusyViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
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
