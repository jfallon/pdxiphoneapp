//
//  AppModalAlertViewController.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppLongTextViewController : UIViewController {

	IBOutlet UITextView *textView;
	IBOutlet UIButton *button;

}

@property (nonatomic,retain) IBOutlet UITextView *textView;
@property (nonatomic,retain) IBOutlet UIButton *button;

- (IBAction)dismissLongTextViewFromButtonClick:(id)sender; 




@end
