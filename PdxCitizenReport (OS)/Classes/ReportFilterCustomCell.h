//
//  ReportFilterCustomCell.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 2/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITableViewCellSwitch;

@interface ReportFilterCustomCell : UITableViewCell {
    IBOutlet UILabel *cellLabel;
    IBOutlet UITableViewCellSwitch *cellSwitch;
    NSString *key;
    NSInteger row;
    NSInteger section;
}

@property (nonatomic,retain) IBOutlet UILabel *cellLabel;
@property (nonatomic,retain) IBOutlet UITableViewCellSwitch *cellSwitch;
@property (nonatomic,retain) NSString *key;
@property NSInteger row;
@property NSInteger section;

- (IBAction)reportFilterSwitchValueChanged:(id)sender;


@end
