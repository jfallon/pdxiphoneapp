//
//  DisplayImageViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/16/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import "DisplayImageViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DataRepository.h"

@implementation DisplayImageViewController

@synthesize scrollView;
@synthesize label;
@synthesize imageView;
@synthesize activityIndicator;
@synthesize image;
@synthesize URL;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.URL != nil) {
		if (DataRepository.sharedInstance.internetIsReachable == YES) {
			[activityIndicator startAnimating];
			ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:self.URL];
			[request setUserInfo:[NSDictionary dictionaryWithObject:@"get_image" forKey:@"request_type"]];
			[request setTimeOutSeconds:60];
			[request setDelegate:self];
			[request startAsynchronous];
		}
		return;
	}
	if (self.image != nil) {
	
		UIImageView *tempImageView = [[UIImageView alloc] initWithImage:self.image];
		self.imageView = tempImageView;
		[tempImageView release];
		scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
		scrollView.maximumZoomScale = 4.0;
		scrollView.minimumZoomScale = 0.25;
		scrollView.clipsToBounds = YES;
		[scrollView addSubview:self.imageView];
		return;
	}
	label.hidden = NO;
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
	[label release]; label = nil;
	[image release]; image = nil;
	[URL release]; URL = nil;
	[imageView release]; imageView = nil;
	[scrollView release]; scrollView = nil;
	[activityIndicator release]; activityIndicator = nil;
    [super dealloc];
}

- (id)initWithImage:(UIImage *)imageToDisplay fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.image = imageToDisplay;
	}
	return self;
}
- (id)initWithURL:(NSURL *)urlToLoad fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.URL = urlToLoad;
	}
	return self;
}

#pragma mark HTTP request success/failure callbacks and supporting methods

- (void)requestFinished:(ASIHTTPRequest *)request {

	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"get_image"]) {
		UIImage *requestImage = [UIImage imageWithData:[request responseData]];
		if (requestImage == nil) {
			label.hidden = NO;
		}
		else {
			UIImageView *tempImageView = [[UIImageView alloc] initWithImage:requestImage];
			self.imageView = tempImageView;
			[tempImageView release];
			scrollView.contentSize = CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height);
			scrollView.maximumZoomScale = 4.0;
			scrollView.minimumZoomScale = 0.5;
			scrollView.clipsToBounds = YES;
			[scrollView addSubview:self.imageView];
			label.hidden = YES;
		}
	}
	[activityIndicator stopAnimating];
	
}
- (void)requestFailed:(ASIHTTPRequest *)request {
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"get_image"]) {
	}
	label.hidden = NO;
	[activityIndicator stopAnimating];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

@end
