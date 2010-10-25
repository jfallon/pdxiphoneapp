//
//  AppProgressViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/29/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppProgressViewController : UIViewController {

	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel		*progressLabel;
}

@property (retain) IBOutlet UIProgressView	*progressView;
@property (retain) IBOutlet UILabel			*progressLabel;

@end
