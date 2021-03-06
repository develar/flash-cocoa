//
//  CustomScroller.m
//  AssetApp
//
//  Created by Vladimir Krivosheev on 01.04.10.
//  Copyright 2010 TWP. All rights reserved.
//

#import "CustomScroller.h"

@implementation CustomScroller : NSScroller

@synthesize highlightArrowId;
@synthesize hasArrow;

BOOL highlightArrowId;

- (id)initWithFrame:(NSRect)frameRect
{	
	hasArrow = YES;
	
	return [super initWithFrame:frameRect];
}

- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)flag
{
	if (hasArrow)
	{
		[super drawArrow:arrow highlightPart:highlightArrowId ? 0 : 1];
	}
}

- (void)drawKnobSlotInRect:(NSRect)rect highlight:(BOOL)highlight
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:0 yRadius:0];
    [[NSColor clearColor] set];
    [path fill];
}

- (BOOL)isOpaque {
	return NO;
}

@end
