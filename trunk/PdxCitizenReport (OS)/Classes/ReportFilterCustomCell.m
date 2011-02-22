//
//  ReportFilterCustomCell.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCellSwitch.h"
#import "ReportFilterCustomCell.h"


@implementation ReportFilterCustomCell

@synthesize cellLabel;
@synthesize cellSwitch;
@synthesize key;
@synthesize row;
@synthesize section;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)dealloc
{
    [cellLabel release]; cellLabel = nil;
    [cellSwitch release]; cellSwitch = nil;
	[key release]; key = nil;
    [super dealloc];
}



- (IBAction)reportFilterSwitchValueChanged:(id)sender 
{
    
}


@end
