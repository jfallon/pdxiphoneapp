//
//  TrackItInstance.h
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


@interface TrackItInstance : NSObject {
	NSInteger number;
	NSInteger category;
	NSString *instanceName;
	NSString *imageInputName;
	NSString *commentsInputName;
	NSString *addressStringInputName;
	NSString *addressXInputName;
	NSString *addressYInputName;
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
@property(nonatomic,copy) NSString *imageInputName;
@property(nonatomic,copy) NSString *commentsInputName;
@property(nonatomic,copy) NSString *addressStringInputName;
@property(nonatomic,copy) NSString *addressXInputName;
@property(nonatomic,copy) NSString *addressYInputName;
@property(nonatomic,copy) NSString *instanceMessage;

@end
