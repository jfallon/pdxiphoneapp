//
//  ReportCustomCell.h
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
