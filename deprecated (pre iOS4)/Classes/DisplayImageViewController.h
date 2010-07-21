//
//  DisplayImageViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import <UIKit/UIKit.h>


@interface DisplayImageViewController : UIViewController <UIScrollViewDelegate> {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *label;
	UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	UIImage *image;
	NSURL *URL;
}

@property(nonatomic,retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UILabel *label;
@property(nonatomic,retain) UIImageView *imageView;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic,retain) UIImage *image;
@property(nonatomic,retain) NSURL *URL;

- (id)initWithImage:(UIImage *)imageToDisplay fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil;
- (id)initWithURL:(NSURL *)urlToLoad fromNibName:(NSString *)nibNameOrNil fromBundle:(NSBundle *)nibBundleOrNil;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;


@end
