//
//  ReportCustomCell.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
