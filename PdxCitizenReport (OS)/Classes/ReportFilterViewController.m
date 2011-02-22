//
//  ReportFilterViewController.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppSettings.h"
#import "DataRepository.h"
#import "CRMReportDefinition.h"
#import "UITableViewCellSwitch.h"
#import "ReportFilterViewController.h"
#import "ReportFilterCustomCell.h"


@implementation ReportFilterViewController

@synthesize table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [table release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[table reloadData];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[[DataRepository sharedInstance] statusCodeValues] count];
    } 
    else {
        return [[[DataRepository sharedInstance] crmReportDefinitionArray] count];
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Show or Hide Reports by Status:";
    }
    else {
        return @"Show or Hide Reports by Type:";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // get or create a resuable table cell
    static NSString *cellIdentifier = @"ReportFilterCustomCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReportFilterCustomCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[ReportFilterCustomCell class]])
			{
				cell = (ReportFilterCustomCell *)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *switchView = (UISwitch *)cell.accessoryView;
                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
				break;
			}
		}
	}
    
    // populate cell
    DataRepository *globalData = [DataRepository sharedInstance];
	ReportFilterCustomCell *customCell = (ReportFilterCustomCell *)cell;
    customCell.section = indexPath.section;
    customCell.row = indexPath.row;
    customCell.cellSwitch.section = indexPath.section;
    customCell.cellSwitch.row = indexPath.row;
    
    if (indexPath.section == 0) {
        customCell.cellLabel.text = [[globalData statusCodeValues] objectAtIndex:indexPath.row];
        customCell.key = [[globalData statusCodeKeys] objectAtIndex:indexPath.row];
        NSNumber *reportStatusIsToggledOn = [[globalData statusCodeIsToggledOn] objectAtIndex:indexPath.row];
        if ([reportStatusIsToggledOn isEqualToNumber:[NSNumber numberWithBool:YES]])
            customCell.cellSwitch.on = YES;
        else
            customCell.cellSwitch.on = NO;
    } 
    else {
        CRMReportDefinition *reportDefinition = [[globalData crmReportDefinitionArray] objectAtIndex:indexPath.row];
        customCell.cellLabel.text = reportDefinition.instanceName;
        customCell.key = [NSString stringWithFormat:@"%d", reportDefinition.category];
        customCell.cellSwitch.on = reportDefinition.visibleInMyReports;
    }
    return cell;
}

- (void) switchChanged:(id)sender {
    
    UITableViewCellSwitch* switchControl = sender;
    NSInteger row = switchControl.row;
    NSInteger section = switchControl.section;
    
    AppSettings *appSettings = [[DataRepository sharedInstance] appSettings];
    if (section == 0) {
        NSMutableArray *statusCodeIsToggledOn = [[DataRepository sharedInstance] statusCodeIsToggledOn];
        if (switchControl.on == YES)
            [statusCodeIsToggledOn replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        else
            [statusCodeIsToggledOn replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:NO]];
        
        appSettings.reportStatusFilterString = [[DataRepository sharedInstance] getReportStatusFilterString];
        [[DataRepository sharedInstance] setMyReportsShouldBeRefreshed:YES];
    }
    else {
        CRMReportDefinition *reportDefinition = [[[DataRepository sharedInstance] crmReportDefinitionArray] objectAtIndex:row];
        reportDefinition.visibleInMyReports = switchControl.on;
        appSettings.categoryFilterString = [[DataRepository sharedInstance] getCategoryFilterString];
        [[DataRepository sharedInstance] setMyReportsShouldBeRefreshed:YES];
    }
}


@end
