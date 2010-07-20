//
//  ReportStatusViewController.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import "ReportStatusViewController.h"
#import "AppBusyViewController.h"
#import "AppProgressViewController.h"
#import "Report.h"
#import "CRMReportDefinition.h"
#import "DataRepository.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DDXML.h"
#import "ReportCustomCell.h"
#import "ReportStatusDetailViewController.h"

@implementation ReportStatusViewController

@synthesize refreshButton;
@synthesize reportsTable;
@synthesize activityIndicator;
@synthesize activityLabel;
@synthesize tableData;
@synthesize tableDataKeys;


- (void)dealloc {
	[refreshButton release]; refreshButton = nil;
	[reportsTable release]; reportsTable = nil;
	[activityIndicator release]; activityIndicator = nil;
	[activityLabel release]; activityLabel = nil;
	[tableDataKeys release]; tableDataKeys = nil;
	[tableData release]; tableData = nil;
    [super dealloc];
}

- (void)showActivityIndicators {
	activityLabel.hidden = NO;
	activityIndicator.hidden = NO;
	reportsTable.hidden = YES;
	[refreshButton setEnabled:NO];
	[activityIndicator startAnimating];
}
- (void)hideActivityIndicators {
	[activityIndicator stopAnimating];	
	[refreshButton setEnabled:YES];
	reportsTable.hidden = NO;
	activityLabel.hidden = YES;
	activityIndicator.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {	
	[super viewDidAppear:animated];
	if (DataRepository.sharedInstance.myReportsShouldBeRefreshed == YES) {
		[self populateUserReportArray];
	} 
	else {
		[self hideActivityIndicators];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (IBAction)refreshUserReportsFromButtonClick:(id)sender { 
	[self populateUserReportArray];
}

- (void)populateUserReportArray {
	
	if ([[DataRepository sharedInstance] internetIsReachableRightNow] == NO || DataRepository.sharedInstance.connectionRequiredForInternet == YES) {
	
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable"
															message:@"Unable to retrieve your reports, your device is not able to reach the internet. Please check your WiFi settings or make sure your device is not in airplane mode." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView setTag:1];
		[alertView show];	
		[alertView release];
		return;
	}
	
	[self showActivityIndicators];
	
	NSMutableArray *userReportArray = [[DataRepository sharedInstance] userReportArray];
	[userReportArray removeAllObjects];
	[reportsTable reloadData];
	
	NSString *address = [[[DataRepository sharedInstance] urlPrefix] stringByAppendingString:[[DataRepository sharedInstance] getAllMyItemsUrlSuffix]];
	NSURL *url = [NSURL URLWithString:address];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:[[DataRepository sharedInstance]verifyValue] forKey:@"verify"];
	[request setPostValue:[[DataRepository sharedInstance]deviceID] forKey:@"device_id"];
	[request setUserInfo:[NSDictionary dictionaryWithObject:@"get_user_reports" forKey:@"request_type"]];
	[request setTimeOutSeconds:30];
	[request setDelegate:self];
	[request startAsynchronous];

}

- (void)buildTableDataSource {

	// this will be a dictionary containing NSMutableArrays with the key being the section header
	NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	NSMutableArray *rawData = [[DataRepository sharedInstance] userReportArray];
	
	int i, count = [rawData count];
	for (i = 0; i < count; i++) {
		Report *report = (Report *)[rawData objectAtIndex:i];
		NSMutableArray *sectionArray = [dictionary objectForKey:report.reportType];
		if (sectionArray == nil) {
			sectionArray = [NSMutableArray array];
			[dictionary setObject:sectionArray forKey:report.reportType];
		}
		[sectionArray addObject:report];
	}
	[self setTableData:dictionary];
	[self setTableDataKeys:[dictionary allKeys]];
}

- (bool)parseUserReportsXml:(NSString *)xmlData {
	
	NSMutableArray *userReportArray = [[DataRepository sharedInstance] userReportArray];	
	NSError **xmlParsingError = nil;
	DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:xmlData options:0 error:xmlParsingError];
	if (xmlDocument != nil) {
		
		DDXMLNode *rootNode = [xmlDocument rootElement];
		NSArray *reportNodeArray = [rootNode children];
		int i, count = [reportNodeArray count];
		for (i = 0; i < count; i++) {
			
			DDXMLElement *reportElement = [reportNodeArray objectAtIndex:i];
			
			Report *userReport = [[Report alloc]init];
			
			DDXMLNode *reportAttribute = [reportElement attributeForName:@"item_id"];
			if (reportAttribute != nil) {
				[userReport setNumber:[[reportAttribute stringValue] integerValue]];
			}
			reportAttribute = [reportElement attributeForName:@"status"];
			if (reportAttribute != nil) {
				[userReport setStatus:[reportAttribute stringValue]];
			}			
			reportAttribute = [reportElement attributeForName:@"iphone_binary_input_value"];
			if (reportAttribute != nil) {
				[userReport setImageID:[[reportAttribute stringValue] integerValue]];
			}			
			reportAttribute = [reportElement attributeForName:@"iphone_input_alias"];
			if (reportAttribute != nil) {
				[userReport setReportType:[reportAttribute stringValue]];
			}			
			reportAttribute = [reportElement attributeForName:@"iphone_text_input_value"];
			if (reportAttribute != nil) {
				[userReport setComments:[reportAttribute stringValue]];
			}					  
			reportAttribute = [reportElement attributeForName:@"iphone_address_input_value_long"];
			if (reportAttribute != nil) {
				[userReport setLongitude:[[reportAttribute stringValue] doubleValue]];
			}			
			reportAttribute = [reportElement attributeForName:@"iphone_address_input_value_lat"];
			if (reportAttribute != nil) {
				[userReport setLatitude:[[reportAttribute stringValue] doubleValue]];
			}
			reportAttribute = [reportElement attributeForName:@"last_updated"];
			if (reportAttribute != nil) {
				[userReport setLastUpdate:[reportAttribute stringValue]];
			}
			reportAttribute = [reportElement attributeForName:@"iphone_status_input_value"];
			if (reportAttribute != nil) {
				[userReport setCustomStatus:[reportAttribute stringValue]];
			}
			[userReportArray addObject:userReport];
			[userReport release];
		}
		[xmlDocument release];
	}
	if ([userReportArray count] > 0) {
		return YES;
	} else {
		return NO;
	}
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"get_user_reports"]) {
		[self hideActivityIndicators];
		DataRepository.sharedInstance.myReportsShouldBeRefreshed = NO;
		NSString *requestString = [request responseString];
		//NSLog(@"User reports HTTP request successful");
		if ([self parseUserReportsXml:requestString] == YES) { 
			//NSLog(@"User reports XML response parsed successfully");
			[self buildTableDataSource];
			[reportsTable reloadData];
			return;
		}
	}	
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	[self hideActivityIndicators];
	if (request.error != nil) {	
		//NSLog(@"Error code = %ld",(long)request.error.code);
	}
	NSString *requestType = [[request userInfo] objectForKey:@"request_type"];
	if ([requestType isEqualToString:@"get_user_reports"]) {
		DataRepository.sharedInstance.myReportsShouldBeRefreshed = YES;
		//NSLog(@"User reports HTTP request failed");
		populateUserReportArrayRetryCount++;
		if (populateUserReportArrayRetryCount <= 3) {
			//NSLog(@"Retry Attempt #%ld",(long)populateUserReportArrayRetryCount);
			[self populateUserReportArray];			
		}
		else {
			//NSLog(@"Giving up after %ld attempts",(long)populateUserReportArrayRetryCount);
		}
	}	

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)table {
	return self.tableData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSString *key = [tableDataKeys objectAtIndex:section];
	if (key != nil) {
		NSMutableArray *sectionArray = [tableData objectForKey:key];
		if (sectionArray != nil) {
			return sectionArray.count;
		}
		else {
			return 0;
		}
	}
	return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *key = [tableDataKeys objectAtIndex:section];
	if (key.length > 0) {
		return key; //[NSString stringWithFormat:@"Type: %@",key];
	}
	return nil; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *cellIdentifier = @"ReportCustomCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
		
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReportCustomCell" owner:nil options:nil];
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass:[ReportCustomCell class]])
			{
				cell = (ReportCustomCell *)currentObject;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				break;
			}
		}
	}
	
	ReportCustomCell *customCell = (ReportCustomCell *)cell;
	NSString *key = [tableDataKeys objectAtIndex:indexPath.section];
	if (key != nil) {
		NSMutableArray *array = [tableData objectForKey:key];
		if (array != nil) {
			Report *report = [array objectAtIndex:indexPath.row];
			if (report != nil) {
				NSString *reportStatus = nil;
				if (report.customStatus.length == 0) {
					reportStatus = [[[DataRepository sharedInstance] statusCodeDictionary] objectForKey:report.status];
					if (reportStatus.length == 0) {
						reportStatus = @"Unknown";
					}
				}
				else {
					reportStatus = report.customStatus;
				}
				customCell.labelLineOne.text = [NSString stringWithFormat:@"Status: %@",reportStatus];
				customCell.labelLineTwo.text = [NSString stringWithFormat:@"Last updated: %@",report.lastUpdate];
				customCell.itemDetailUrlParameters = [NSString stringWithFormat:@"?device_id=%@&item_id=%ld",DataRepository.sharedInstance.deviceID,(long)report.number];
				customCell.reportNumber = report.number;
				return cell;
			}
		}
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		ReportCustomCell *customCell = (ReportCustomCell *)cell;
		NSMutableArray *reportArray = [[DataRepository sharedInstance] userReportArray];
		DataRepository.sharedInstance.selectedReport = nil;
		for (Report *report in reportArray) {
			if (report.number == customCell.reportNumber) {
				DataRepository.sharedInstance.selectedReport = report;
				break;
			}
		}
		DataRepository.sharedInstance.getItemDetailUrlParameters = customCell.itemDetailUrlParameters;
		ReportStatusDetailViewController *controller = [[ReportStatusDetailViewController alloc] initWithNibName:@"ReportStatusDetailView" bundle:nil];
		[controller setTitle:@"Detail"];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	// alert for report detail not available yet
	if ([alertView tag] == 0) {
		return;
	}
	
	// alert for network not reachable
	if ([alertView tag] == 1) {
		return;
	}
}




@end
