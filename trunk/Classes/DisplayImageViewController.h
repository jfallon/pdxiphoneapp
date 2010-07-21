//
//  DisplayImageViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/16/10.
//  Copyright 2010 City of Portland. All rights reserved.
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
