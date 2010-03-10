//
//  PdxBoundary.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface PdxBoundary : NSObject {
	float xCoords[35];
	float yCoords[35];
}

- (bool)locationIsInside:(CLLocation *)location;


@end
