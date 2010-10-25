//
//  TrackItInstance.h
//  PdxCitizenReport
//
//  Created by Mike Quetel on 12/22/09.
//  Copyright 2009 City of Portland. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CRMReportDefinition : NSObject {
	NSInteger number;
	NSInteger category;
	NSString *instanceName;
	NSString *imageFieldName;
	NSString *commentsFieldName;
	NSString *addressFieldName;
	NSString *xCoordFieldName;
	NSString *yCoordFieldName;
	NSString *instanceMessage;
	bool imageRequired;
	bool addressRequired;
	bool commentsRequired;
}

@property NSInteger number;
@property NSInteger category;
@property bool imageRequired;
@property bool addressRequired;
@property bool commentsRequired;
@property(nonatomic,copy) NSString *instanceName;
@property(nonatomic,copy) NSString *imageFieldName;
@property(nonatomic,copy) NSString *commentsFieldName;
@property(nonatomic,copy) NSString *addressFieldName;
@property(nonatomic,copy) NSString *xCoordFieldName;
@property(nonatomic,copy) NSString *yCoordFieldName;
@property(nonatomic,copy) NSString *instanceMessage;

@end
