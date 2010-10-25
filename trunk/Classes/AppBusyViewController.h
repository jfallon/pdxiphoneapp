//
//  AppBusyViewController.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 12/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppBusyViewController : UIViewController {
	
	IBOutlet UIActivityIndicatorView	*activityIndicatorView;
	IBOutlet UILabel					*activityIndicatorLabel;
}

@property(retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(retain) IBOutlet UILabel *activityIndicatorLabel;

- (void)startProgressIndicator;
- (void)stopProgressIndicator;

@end
