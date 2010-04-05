//
//  CustomScroller.h
//  AssetApp
//
//  Created by Vladimir Krivosheev on 01.04.10.
//  Copyright 2010 TWP. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CustomScroller : NSScroller {
	BOOL highlightArrowId;
	BOOL hasArrow;
}

@property (assign) BOOL highlightArrowId;
@property (assign) BOOL hasArrow;

@end
