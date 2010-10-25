//
//  ReportMapAnnotationView.m
//  PdxCitizenReport
//
//  Created by Michael Quetel on 1/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  code adapted from: http://hollowout.blogspot.com/2009/07/mapkit-annotation-drag-and-drop-with.html
//  and
//  http://github.com/digdog/MapKitDragAndDrop

#import "ReportMapAnnotationView.h"
#import "ReportMapAnnotation.h"

@implementation ReportMapAnnotationView

@synthesize map;

- (void)dealloc {
	[map release]; map = nil;
	[super dealloc];
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self != nil) {
		UIImage* pinImage = [UIImage imageNamed:@"Pin.png"];
		if (pinImage == nil) {
			return nil;
		}
		self.image = pinImage;
		self.canShowCallout = NO;
		self.multipleTouchEnabled = NO;
		map = nil;
	}
	return self;
}

@end

@implementation ReportMapAnnotationView (TouchBeginMethods)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    // The view is configured for single touches only.
    UITouch* aTouch = [touches anyObject];
    startLocation = [aTouch locationInView:[self superview]];
    originalCenter = self.center;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch* aTouch = [touches anyObject];
    CGPoint newLocation = [aTouch locationInView:[self superview]];
    CGPoint newCenter;
	
    // If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - startLocation.x) > 5.0) || (abs(newLocation.y - startLocation.y) > 5.0)) {
		isMoving = YES;
	}
    // If dragging has begun, adjust the position of the view.	
    if (isMoving) {
        newCenter.x = originalCenter.x + (newLocation.x - startLocation.x);
        newCenter.y = originalCenter.y + (newLocation.y - startLocation.y);
        self.center = newCenter;
    }
    else {   
		// Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];
	}
}

@end

@implementation ReportMapAnnotationView (TouchEndMethods)

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (isMoving) {
        // Update the map coordinate to reflect the new position.
        CGPoint newCenter = self.center;
        ReportMapAnnotation* theAnnotation = self.annotation;
        CLLocationCoordinate2D newCoordinate = [map convertPoint:newCenter toCoordinateFromView:self.superview];
        [theAnnotation changeCoordinate:newCoordinate];
        // Clean up the state information.
        startLocation = CGPointZero;
        originalCenter = CGPointZero;
        isMoving = NO;
    }
    else {
        [super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (isMoving) {
        // Move the view back to its starting point.
        self.center = originalCenter;
        // Clean up the state information.
        startLocation = CGPointZero;
        originalCenter = CGPointZero;
        isMoving = NO;
    }
    else {
        [super touchesCancelled:touches withEvent:event];
	}
}

@end