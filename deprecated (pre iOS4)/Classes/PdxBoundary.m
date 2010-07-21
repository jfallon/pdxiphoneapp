//
//  PdxBoundary.m
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/21/09.
//  Copyright 2009 City of Portland.
//
//  Portions Copyright 1994-2006 W Randolph Franklin (WRF)
//  http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2 as
//  published by the Free Software Foundation: http://www.gnu.org/licenses/gpl-2.0.txt
//

#import "PdxBoundary.h"
#import <CoreLocation/CoreLocation.h>

@implementation PdxBoundary


-(id)init {

	self = [super init];
    if (self != nil) {
		// coordinate pairs that define a simplified City of Portland boundary
		xCoords[0] = -122.764273482324; 
		yCoords[0] = 45.655554637746;
		xCoords[1] = -122.702403202537;
		yCoords[1] = 45.6187116938937;
		xCoords[2] = -122.690711190107;
		yCoords[2] = 45.6286944080437;
		xCoords[3] = -122.641795627773;
		yCoords[3] = 45.6129210615254;
		xCoords[4] = -122.612876805976;
		yCoords[4] = 45.6126851140898;
		xCoords[5] = -122.586994389802;
		yCoords[5] = 45.6054526451392;
		xCoords[6] = -122.57715828134;
		yCoords[6] = 45.5966417838354;
		xCoords[7] = -122.532402904163;
		yCoords[7] = 45.5727862029936;
		xCoords[8] = -122.470970578188;
		yCoords[8] = 45.5622985782448;
		xCoords[9] = -122.469277572091;
		yCoords[9] = 45.5451207366167;
		xCoords[10] = -122.488325836407;
		yCoords[10] = 45.5463337694745;
		xCoords[11] = -122.48665806736;
		yCoords[11] = 45.5404557261804;
		xCoords[12] = -122.49323247247;
		yCoords[12] = 45.5403419093664;
		xCoords[13] = -122.49292185098;
		yCoords[13] = 45.5210856321073;
		xCoords[14] = -122.478308035901;
		yCoords[14] = 45.521081342262;
		xCoords[15] = -122.474715037096;
		yCoords[15] = 45.4702921381664;
		xCoords[16] = -122.491887344921;
		yCoords[16] = 45.4707659490151;
		xCoords[17] = -122.491230865052;
		yCoords[17] = 45.4520289702228;
		xCoords[18] = -122.653630250684;
		yCoords[18] = 45.4524351309282;
		xCoords[19] = -122.663469556816;
		yCoords[19] = 45.4424900663915;
		xCoords[20] = -122.661197825358;
		yCoords[20] = 45.4307181232791;
		xCoords[21] = -122.747637425353;
		yCoords[21] = 45.4303412860042;
		xCoords[22] = -122.747801772923;
		yCoords[22] = 45.4621873876939;
		xCoords[23] = -122.75691953741;
		yCoords[23] = 45.4620084640207;
		xCoords[24] = -122.757286470332;
		yCoords[24] = 45.4712478064152;
		xCoords[25] = -122.749980917379;
		yCoords[25] = 45.4711343774928;
		xCoords[26] = -122.749926111197;
		yCoords[26] = 45.5250731077031;
		xCoords[27] = -122.786447516748;
		yCoords[27] = 45.5246090412258;
		xCoords[28] = -122.787002500818;
		yCoords[28] = 45.5474573397718;
		xCoords[29] = -122.821273297381;
		yCoords[29] = 45.5899207334168;
		xCoords[30] = -122.839570533467;
		yCoords[30] = 45.5900637663305;
		xCoords[31] = -122.838944662987;
		yCoords[31] = 45.6103673568999;
		xCoords[32] = -122.82395280584;
		yCoords[32] = 45.6106710794386;
		xCoords[33] = -122.766408163769;
		yCoords[33] = 45.6541968585544;
		xCoords[34] = -122.764273482324;
		yCoords[34] = 45.655554637746;
	}
	return self;
}

- (bool)locationIsInside:(CLLocation *)location {
	
	// code adapted from http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
	bool returnValue = NO;
	if (location != nil) {
		
		int i,j,vertexCount = 35;
		float textX = location.coordinate.longitude;
		float testY = location.coordinate.latitude;
		
		for (i = 0, j = vertexCount-1; i < vertexCount; j = i++) {
			if ( ((yCoords[i]>testY) != (yCoords[j]>testY)) &&
				(textX < (xCoords[j]-xCoords[i]) * (testY-yCoords[i]) / (yCoords[j]-yCoords[i]) + xCoords[i]) )
				returnValue = !returnValue;
		}		
	}
	return returnValue;
}

@end
