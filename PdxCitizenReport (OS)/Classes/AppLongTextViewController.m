//
//  AppModalAlertViewController.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppLongTextViewController.h"


@implementation AppLongTextViewController

@synthesize textView;
@synthesize button;

- (void)viewDidLoad {
    [super viewDidLoad];
	// set background image of UIButtons, this is done at runtime because the images are dynamically stretched based on button size
	[button setBackgroundImage:[[UIImage imageNamed:@"grayButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:22] forState:UIControlStateNormal];
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
	[textView release]; textView = nil;
	[button release]; button = nil;
	[super dealloc];
}

- (IBAction)dismissLongTextViewFromButtonClick:(id)sender {
	[self.view removeFromSuperview];
}


@end
