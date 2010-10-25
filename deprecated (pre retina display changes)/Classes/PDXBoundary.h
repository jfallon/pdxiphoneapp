//
//  PdxBoundary.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 2/8/10.
//  Copyright 2010 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface PDXBoundary : NSObject {
	float xCoords[35];
	float yCoords[35];
}

- (bool)locationIsInside:(CLLocation *)location;


@end
