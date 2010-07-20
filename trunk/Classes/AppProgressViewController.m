//
//  AppProgressViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/29/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "AppProgressViewController.h"

@implementation AppProgressViewController

@synthesize progressView;
@synthesize progressLabel;

- (void)dealloc {
	[progressView release]; progressView = nil;
	[progressLabel release]; progressLabel = nil;
	[super dealloc];
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

@end
