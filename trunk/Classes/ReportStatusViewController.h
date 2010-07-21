//
//  ReportStatusViewController.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/11/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIHTTPRequest;
@class ReportStatusDetailViewController;

@interface ReportStatusViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {

	IBOutlet UIBarButtonItem *refreshButton;
	IBOutlet UITableView *reportsTable;
	IBOutlet UIActivityIndicatorView *activityIndicator;
	IBOutlet UILabel *activityLabel;
	
	NSInteger populateUserReportArrayRetryCount;
	NSMutableDictionary *tableData;
	NSArray *tableDataKeys;
}

@property (nonatomic,retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic,retain) IBOutlet UITableView *reportsTable;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,retain) IBOutlet UILabel *activityLabel;
@property (nonatomic,retain) NSMutableDictionary *tableData;
@property (nonatomic,retain) NSArray *tableDataKeys;

- (IBAction)refreshUserReportsFromButtonClick:(id)sender;

- (void)showActivityIndicators;
- (void)hideActivityIndicators;

- (void)populateUserReportArray;
- (bool)parseUserReportsXml:(NSString *)xmlData;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
