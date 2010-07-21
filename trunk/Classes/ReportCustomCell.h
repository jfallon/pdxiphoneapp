//
//  ReportCustomCell.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Report;


@interface ReportCustomCell : UITableViewCell {
	NSString *itemDetailUrlParameters;
	IBOutlet UILabel *labelLineOne;
	IBOutlet UILabel *labelLineTwo;
	NSInteger reportNumber;
}

@property (nonatomic,copy) NSString *itemDetailUrlParameters;
@property (nonatomic,retain) IBOutlet UILabel *labelLineOne;
@property (nonatomic,retain) IBOutlet UILabel *labelLineTwo;
@property NSInteger reportNumber;

@end
