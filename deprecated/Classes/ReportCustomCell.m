//
//  ReportCustomCell.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "ReportCustomCell.h"
#import "Report.h"

@implementation ReportCustomCell

@synthesize labelLineOne;
@synthesize labelLineTwo;
@synthesize itemDetailUrlParameters;
@synthesize reportNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


- (void)dealloc {
	[itemDetailUrlParameters release]; itemDetailUrlParameters = nil;
	[labelLineOne release]; labelLineOne = nil;
	[labelLineTwo release]; labelLineTwo = nil;
    [super dealloc];
}


@end
