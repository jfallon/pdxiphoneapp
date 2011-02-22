//
//  UITableViewCellSwitch.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/15/11.
//  Copyright 2011 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UITableViewCellSwitch : UISwitch {
    NSInteger row;
    NSInteger section;
}

@property NSInteger row;
@property NSInteger section;

@end
