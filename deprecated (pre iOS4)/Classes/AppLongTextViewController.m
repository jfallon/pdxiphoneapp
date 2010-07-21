//
//  AppModalAlertViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "AppLongTextViewController.h"


@implementation AppLongTextViewController

@synthesize textView;
@synthesize button;

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
	[textView release]; textView = nil;
	[button release]; button = nil;
	[super dealloc];
}

- (IBAction)dismissLongTextViewFromButtonClick:(id)sender {
	[self.view removeFromSuperview];
}


@end
