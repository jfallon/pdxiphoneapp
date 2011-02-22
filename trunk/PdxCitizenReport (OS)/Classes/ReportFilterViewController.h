//
//  ReportFilterViewController.h
//  PdxCitizenReport
//
//  Created by Michael Quetel on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReportFilterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *table;
}

@property (nonatomic,retain) IBOutlet UITableView *table;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;


@end
