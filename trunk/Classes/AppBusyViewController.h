//
//  AppBusyViewController.h
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


@interface AppBusyViewController : UIViewController {
	
	IBOutlet UIActivityIndicatorView	*activityIndicatorView;
	IBOutlet UILabel					*activityIndicatorLabel;
}

@property(retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property(retain) IBOutlet UILabel *activityIndicatorLabel;

- (void)startProgressIndicator;
- (void)stopProgressIndicator;

@end
